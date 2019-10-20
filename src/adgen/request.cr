require "./api"
require "./auth"
require "./host"

class Adgen::Request
  var api  : Api
  var auth : Auth
  var host : Host = Host.default

  def initialize(@api = nil, @auth = nil, @host = nil)
  end

  delegate method, path, headers, to: api
  
  def url : String
    u = host.uri.dup
    u.path = api.request_path
    u.to_s
  end

  # url without query_string for security reason
  def safe_url : String
    url.sub(/\?.*$/, "")
  end

  def authorize! : Request
    auth.authorize!(self)
    return self
  end

  # "GET http://..."
  def to_s(io : IO)
    io << url
  end
end
