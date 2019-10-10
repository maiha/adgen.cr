require "./proto/**"
require "./errors"
require "./data/**"
require "./callback"
require "./strategy"
require "./request"
require "./response"

module Adgen
  class Client
    include Adgen::Callback
    include Adgen::Strategy

    var api  : Api
    var auth : Auth = Adgen::Auth::AccessToken.new("")
    var host : Host = Host.default

    var logger : Logger

    def initialize(api = nil, auth = nil, host = nil, logger : Logger? = nil)
      self.api  = api
      self.auth = auth
      self.host = host

      @logger = logger || Logger.new(nil)
      self.strategy = Strategy::Libcurl.new
    end

    ######################################################################
    ### shortcuts for Adgen class

    def api=(path : String)
      @api = Adgen::Api::Get.parse(path)
    end

    def auth=(access_token : String)
      @auth = Adgen::Auth::AccessToken.new(access_token)
    end

    def host=(host : String)
      @host = Adgen::Host.new(host)
    end

    def strategy=(v : Strategy::Base) : Client
      @strategy = v
      strategy.logger = logger
      return self
    end

    def dryrun! : Client
      self.strategy= Adgen::Strategy::Dryrun.new
    end

    def libcurl! : Client
      self.strategy= Adgen::Strategy::Libcurl.new
    end

    def authorized_url!(url : String)
      @auth = Adgen::Auth::Nothing.new
      case url
      when %r{\Ahttps?://(.*?)(/.*)\Z}
        @api = Adgen::Api::GetFixed.new($2)
        self.host = url
      else
        @api = Adgen::Api::GetFixed.new(url)
      end
    end

    ######################################################################
    ### API methods

    # See ./api/*.cr
    
    ######################################################################
    ### HTTP methods
    
    def get(path : String, data = {} of String => String) : Response
      api = Api::Get.parse(path)
      api.data.merge!(data)
      execute(api: api)
    end

    def post(path : String, data = {} of String => String) : Response
      api = Api::Post.parse(path)
      api.data.merge!(data)
      execute(api: api)
    end

    ######################################################################
    ### internal methods

    def request(api : Api? = nil, auth : Auth? = nil, host : Host? = nil)  : Request
      Request.new(api || api?, auth || auth?, host || host?)
    end

    def request(req : Request) : Request
      req
    end

    def validate(req : Request)
      req.api?  || raise "api not found"
      req.auth? || raise "auth not found"
      req.host? || raise "host not found"
      req.authorize!
    end
  end
end
