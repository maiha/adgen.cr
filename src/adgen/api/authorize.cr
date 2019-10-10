module Adgen
  class Client
    def authorize!(email : String, password : String) : Adgen::Proto::Token
      preserved_auth = @auth
      
      if email.empty?
        raise Adgen::Fatal.new("authorize! got empty email")
      end

      if password.empty?
        raise Adgen::Fatal.new("authorize! got empty password")
      end

      @auth = Adgen::Auth::Nothing.new
      res = post("/api/v2/tokens", data: {"email" => email, "password" => password})
      res.success!
      pb = Adgen::Response::Token.from_json(res.body).to_pb(email: email)
      return pb

    ensure
      self.auth = preserved_auth
    end
  end
end
