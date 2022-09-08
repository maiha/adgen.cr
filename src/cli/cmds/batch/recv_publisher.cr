class Cmds::BatchCmd
  # cache config values
  private var retry_attempts : Int32
  private var visited_urls = Set(String).new

  private def load_publisher_ids : Array(Int32)
    config.batch_publisher_ids
  end
  
  private def recv_publisher(name, house, parser)
    hint = "[recv] #{name}"
    
    # We should not check house.meta_done because publisher_ids may be changed
    # if msg = house.meta[META_DONE]?
    #   update_status "#{hint} (already #{msg})", logger: "INFO"
    #   return false
    # end

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
      recv_publisher_impl(name, label, room, parser, publisher_id, i)
      done_count += 1 if room.meta[META_DONE]?
    end

    # mark meta.done if all metas have been finished.
    record_count = house.load.size # not use house.count to avoid cached count in meta
    if done_count == publisher_ids.size
      house.meta[META_DONE] = "got #{record_count}"
    end

    recv.stop

    # job summary
    msg = "#{hint} got #{record_count} records (in recv: #{recv})"
    update_status msg, logger: "INFO", flush: true
  end

  private def recv_publisher_impl(name, hint, house, parser, publisher_id, loop_counter)
    @retry_attempts = 0       # reset retry

    # if done, nothing to do
    if msg = house.meta[META_DONE]?
      msg = "%s (already %s)" % [hint, msg]
      update_status msg, logger: "INFO", flush: true
      return false
    end

    # if 400, nothing to do
    if house.meta[META_STATUS]? == "400"
      msg = "%s (skip: ERROR 400)" % [hint]
      if config.skip_400?(name)
        update_status msg, logger: "INFO", flush: true
        return false
      else
        update_status msg, logger: "ERROR", flush: true
        raise msg
      end
    end

    # check resumable url, or build initial url
    if url = house.resume?
      logger.info "%s found suspended job" % [hint]
    else
      params = {"PUBLISHER_ID" => publisher_id.to_s}
      if batch_target_end_at = config.batch_target_end_at?
        params["TARGET_EMD_AT"] = Pretty::Date.parse?(batch_target_end_at).to_s.split[0]
      end
      url = url_builder(name, params).call
      house.checkin(url)
      logger.debug "%s created new url: %s" % [hint, url]
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

      # TODO: max_loop_limit
      # if loop_counter > max_loop_limit
      #   raise "#{label} reached max loop limit(#{max_loop_limit})"
      # end        

      # Due to the short expiration date of the token, it may be invalidated on rerun after a timeout.
      # Therefore, the token is updated every time just before execution.
      client = new_client(refresh_token: true)
      client.api = unauthed_url
      url = client.request.authorize!.url # Embeds access token
      
      begin
        recv_impl(client, url, house, parser, hint)
        break
      rescue err : Adgen::Api::Error
        code = err.response?.try(&.code) || -1
        case code
        when 404
          if config.skip_404?(name)
            # For the new API, ignore 404 without making an error
            msg = "%s (skip: ERROR 404)" % [hint]
            house.meta[META_ERROR] = msg
            update_status msg, logger: "WARN", flush: true
            return false
          else
            raise err
          end
        when 500..599
          # retry for server errors
          msg = "%s %s" % [label, err]
          self.retry_attempts += 1
          if retry_attempts < max_attempts
            update_status msg, logger: "WARN", flush: true
          else
            raise msg
          end
        else
          # otherwise, raise as fatal
          raise err
        end
      end
    end

    recv.stop

    msg = "%s %s [%s]" % [hint, house.count, recv.last.to_s]
    update_status msg, logger: "INFO", flush: true

    return true

  rescue err
    house.meta[META_ERROR] = err.to_s if house
    raise err
  end
end
