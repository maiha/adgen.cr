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

  class RetryableError < Exception
    def initialize(err)
      super(err.to_s, cause: err)
    end
  end

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

    recv.start

    # iterate job
    done_count = 0
    publisher_ids = load_publisher_ids
    publisher_ids.each_with_index do |publisher_id, i|
      # publisher_id: 3
      # house       : "20191018/Adgen::Proto::NativePureAd"
      # room        : "20190912/Adgen::Proto::NativePureAd/data/3"
      room  = house.chdir(File.join(house.dir, "data", publisher_id.to_s))
      label = "%s(%s/%s)[%s]" % [hint, i+1, publisher_ids.size, publisher_id]
      recv_native_pure_ad_impl(name, label, room, parser, publisher_id, i)
      done_count += 1 if room.meta[META_DONE]?
    end

    # mark meta.done if all metas have been finished.
    record_count = house.count
    if done_count == publisher_ids.size
      house.meta[META_DONE] = "got #{record_count}"
    end

    recv.stop

    # job summary
    msg = "#{hint} got #{record_count} records (in recv: #{recv})"
    update_status msg, logger: "INFO"
  end

  def recv_native_pure_ad_impl(name, hint, house, parser, publisher_id, loop_counter)
    @retry_attempts = 0       # reset retry

    # if done, nothing to do
    if msg = house.meta[META_DONE]?
      logger.info "%s (already %s)" % [hint, msg]
      return false
    end

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
    
    # check resumable url, or build initial url
    if url = house.resume?
      logger.info "%s found suspended job" % [hint]
    else
      url = url_builder(name, {"PUBLISHER_ID" => publisher_id.to_s}).call
      house.checkin(url)
    end

    loop_counter = 0
    self.retry_attempts = 0
    max_attempts = config.batch_max_attempts
    recv.start

    while (unauthed_url = house.resume?) && !house.meta[META_DONE]?
      loop_counter += 1 if retry_attempts == 0 # increment only when not retry

      label = "#{hint}##{loop_counter}"
      if retry_attempts > 0
        label = "#{label}(retry #{retry_attempts})"
      end

      if loop_counter > max_attempts
        raise "#{label} reached max loop limit(#{max_attempts})"
      end        

      client.api = unauthed_url
      url = client.request.authorize!.url # Embeds access token
      
      begin
        recv_impl_main(client, url, house, parser)
        break
      rescue err : RetryableError
        update_status err.to_s, logger: "INFO"
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

    begin
      res.success!
      pbs = parser.from_json(res.body).map(&.to_pb)
      house.write(pbs, {META_DONE => "got #{pbs.size}"})
    rescue err : Adgen::Api::Error
      if res.server_error?
        # retry
        raise RetryableError.new(err)
      else
        # fatal
        raise err
      end
    end
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
