# add methods to open class
class Cmds::BatchCmd
  # internal variables
  var http_house = house(HttpCall)
  var pb_logging = config.batch_pb_logging?

  private macro load(klass)
    disk.measure {
      house({{klass}}).load
    }
  end
  
  private macro save(klass, pbs)
    disk.measure {
      house({{klass}}).save({{pbs}})
    }
  end

  private macro house(klass)
    Protobuf::House({{klass}}).new(File.join(today_dir, {{klass.stringify}}), logger: pb_logger, watch: disk)
  end

  private def house(name)
    Protobuf::House(HttpCall).new(File.join(today_dir, name, "HttpCall"), logger: pb_logger, watch: disk)
  end

  # recv/
  #  + 20190912/
  #     + native_pure_ads/
  #        + HttpCall/
  private def http_call_house(name)
    Protobuf::House(HttpCall).new(File.join(today_dir, name, "HttpCall"), logger: pb_logger, watch: disk)
  end

  private def build_http_call(req : Adgen::Request, res : Adgen::Response?)
    build_http_call(req.url, req.method.to_s, res)
  end

  private def build_http_call(url : String, method : String, res : Adgen::Response?)
    pb = HttpCall.new(
      url: url,
      method: method,
      header: "",               # TODO: how to get request header in libcurl
      body: "",                 # TODO: how to get request body in libcurl
      requested_at: Datetime.new(res.try(&.requested_at) || Pretty.now),
    )
    if res
      pb.responsed_at = Datetime.new(res.responsed_at)
      pb.status       = res.code
      pb.res_header   = res.headers.to_h.to_json
      pb.res_body     = res.body
    end
    return pb
  end

  private def pb_logger
    pb_logging ? logger : Logger.new(nil)
  end
end
