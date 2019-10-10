struct Adgen::Proto::Token
  def to_s(io : IO)
    expire = expired_at_str || "(---)"
    # value  = api_token.try{|i| i[0..19] + "..."}
    io << "%s (expire: %s)" % [email, expire]
  end

  def value : String
    token || raise Adgen::TokenError.new("no token value")
  end

  def expired_at : Time
    s = expired_at_str || raise Adgen::TokenExpired.new("no expired_at")
    Pretty::Time.parse(s)
  end

  def valid! : Adgen::Proto::Token
    value                       # may cause an error when empty
    if expired_at < Time.now
      raise Adgen::TokenExpired.new("token has been expired at '#{expired_at}'")
    end

    return self
  end
end
