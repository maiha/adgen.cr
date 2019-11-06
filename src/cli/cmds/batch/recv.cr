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

  {% begin %}
  def recv_impl
    {% for klass in PUBLISHER_MODEL_CLASS_IDS %}
      {% name   = klass.stringify.underscore %}
      {% proto  = "Adgen::Proto::#{klass}".id %}
      {% parser = "Array(Adgen::#{klass})".id %}

      if enabled?({{proto}})
        recv_publisher({{name}}, house({{proto}}), {{parser}})
        flush_status_log
      end
    {% end %}
  end
  {% end %}

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
