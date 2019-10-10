module Adgen::Api
  class Post
    include Api

    def initialize(@path : String, @data : Hash(String, String)? = nil, @form : Hash(String, String)? = nil)
      @method = Method::POST
    end

    def request_path : String
      build_request_path
    end
    
    def apply_access_token!(token : String)
      data["token"] = token
    end

    def validate!
      # NOP
    end
  end
end
