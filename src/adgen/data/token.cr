struct Adgen::Proto::Token
  def to_s(io : IO)
    valid!
    io << "%s (expire: %s)" % [email, expired_at.to_s("%F %T")]
  rescue err : Adgen::TokenExpired
    io << "%s (%s)" % [email, err]
  rescue err
    io << "%s (expire: %s) # %s" % [email, expired_at_str, err.to_s]
  end

  def value : String
    token || raise Adgen::TokenError.new("no token value")
  end

  def expired_at : Time
    s = expired_at_str || raise Adgen::TokenExpired.new("no expired_at")
    Pretty::Time.parse(s, location: Time::Location.local)
  end

  def valid! : Adgen::Proto::Token
    value                       # may cause an error when empty

    if expired_at < Time.now
      raise Adgen::TokenExpired.new("expired: '#{expired_at}'")
    end

    return self
  end
end
