class Adgen::Response::Token
  # ```json
  # {
  #   "token": "eyJ0eX...",
  #   "expires_in": 600
  # }
  # ```
  JSON.mapping({
    token: String,
    expires_in: Int64
  })

  def to_pb(email : String) : Adgen::Proto::Token
    value = token || raise Adgen::Error.new("no token in json")
    at_s  = expires_in.try{|sec| (Pretty::Time.now + sec.seconds).to_s("%F %T")} || raise Adgen::Error.new("no expires_in in json")
    Adgen::Proto::Token.new(email: email, token: value, expired_at_str: at_s)
  end
end

