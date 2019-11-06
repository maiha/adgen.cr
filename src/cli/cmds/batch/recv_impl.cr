# ```
# recv/
#  + 20190912/
#     + Adgen::Proto::NativeHouseAd/
#         + meta/
#            + done # => ""
#         + data/
#            + 00001.pb.gz
#     + Adgen::Proto::NativePureAd/
#         + data/
#            + 00001.pb.gz
# ```

# add methods to open class
class Cmds::BatchCmd
  private def recv_impl(client, url, house, parser, hint)
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
      logger.debug "#{hint} #{url}"
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
end
