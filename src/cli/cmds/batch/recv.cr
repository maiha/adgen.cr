# ```
# recv/
#  + 20190912/
#     + native_pure_ads/
#        + HttpCall/
#           + meta/
#              + done # => ""
#           + data/
#              + 00001.pb.gz
# ```

# add methods to open class
class Cmds::BatchCmd
  include ::Cli::Helpers::Token

  META_DONE         = "done"
  META_STATUS       = "status"
  META_CURRENT_URL  = "current_url"
  META_INFO         = "info"
  META_WARN         = "warn"
  META_ERROR        = "error"

  # cache config values
  private var skip_400 : Bool          = config.batch_skip_400?
  private var retry_attempts : Int32

  private var visited_urls = Set(String).new

  def load_publisher_ids : Array(Int32)
    config.batch_publisher_ids
  end

  def recv_native_pure_ad
    name   = "native_pure_ad"
    hint   = "[recv] #{name}"
    house  = house(Adgen::Proto::NativePureAd)
    parser = Array(Adgen::NativePureAd)
    
    # check done
    if msg = house.meta[META_DONE]?
      update_status "#{hint} (already #{msg})", logger: "INFO"
      return false
    end

    # check already fetched
    already_fetched_publisher_ids = house.load.map(&.publisher_id)

    recv.start

    # iterate job
    done_count = 0
    publisher_ids = load_publisher_ids
    publisher_ids.each_with_index do |publisher_id, i|
      label = "%s(%s/%s)[%s]" % [hint, i+1, publisher_ids.size, publisher_id]
      if already_fetched_publisher_ids.includes?(publisher_id)
        msg = "%s (skip: cached)" % [hint]
        update_status msg, logger: "INFO"
      else
        recv_native_pure_ad_impl(name, label, house, parser, publisher_id, i)
      end
    end

    recv.stop

    count = house.tmp.load.size
    house.commit({META_DONE => "got #{count}"})

    # job summary
    msg = "#{hint} got #{count} [#{recv.last}]"
    update_status msg, logger: "INFO"
  end

  def recv_native_pure_ad_impl(name, hint, house, parser, publisher_id, loop_counter)
    @retry_attempts = 0       # reset retry

    # if 400, nothing to do
    if house.meta[META_STATUS]? == "400"
      msg = "%s (skip: ERROR 400)" % [hint]
      if skip_400
        update_status msg, logger: "INFO"
        return false
      else
        update_status msg
        raise msg
      end
    end

    client = new_client(refresh_token: true)
    client.api = url_builder(name, {"PUBLISHER_ID" => publisher_id.to_s}).call
    url = client.request.authorize!.url # Embeds access token

    self.retry_attempts = 0
    max_attempts = config.batch_max_attempts
    recv.start

    while true
      label = "#{hint}##{loop_counter}"
      if retry_attempts > 0
        label = "#{label}(retry #{retry_attempts})"
      end

      begin
        recv_impl_main(client, url, house, parser)
        break
      rescue err
        self.retry_attempts += 1
      end
    end

    recv.stop

    msg = "%s %s [%s]" % [hint, house.count, recv.last.to_s]
    update_status msg, logger: "INFO"

    return true

  rescue err
    house.meta[META_ERROR] = err.to_s if house
    raise err
  end

  private def recv_impl_main(client, url, house, parser)
    client.authorized_url!(url)

    # validte url before execute
    client.before_execute {|req|
      url = req.url
      case url
      when /\s/
        raise "[BUG] url contains spaces: #{url}"
      when /\btoken=/
        visited_urls.includes?(url) &&
          raise "[BUG] already visited: #{url}"
      else
        raise "[BUG] no access_token: #{url}"
      end
    }

    client.after_execute {|req, res|
      if res.try{|r| r.success? && r.client_error? }
        visited_urls << req.url
      end
    }

    api.start
    res = client.execute
    api.stop

    # write status into meta
    house.meta[META_STATUS] = res.code.to_s

    res.success!
    pbs = parser.from_json(res.body).map(&.to_pb)
    house.tmp(pbs)
  end

  private def new_client(api : String? = nil, refresh_token = false)
    client = config.adgen_client
    client.api = api
    client.after_execute {|req, res|
      pb = build_http_call(req, res)
      http_house.save(pb)
    }
    if refresh_token
      refresh_token!(client)
    end
    return client
  end

  private def refresh_token!(client)
    logger.debug "[API] get token"
    token = client.authorize!(config.api_email, config.api_password)
    logger.debug "[API] get token: #{token}"
    save_token(token)           # Cli::Helpers::Token
    token.valid!
    client.auth = token.value
    logger.info "[API] refresh token: #{token}"
  end
end
