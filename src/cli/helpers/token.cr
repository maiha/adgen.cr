module Cli::Helpers::Token
  var token_path : String = config.api_token_path
  
  private def save_token(token : Adgen::Proto::Token)
    io = IO::Memory.new
    token.to_protobuf(io)
    io.rewind
    Pretty::File.write(token_path, io)
  end

  private def load_token? : Adgen::Proto::Token?
    io = File.open(token_path)
    Adgen::Proto::Token.from_protobuf(io)
  rescue Errno
    nil
  ensure
    io.try(&.close)
  end

  private def active_token : Adgen::Proto::Token
    token = current_token
    token.valid!
    return token
  end

  private def current_token : Adgen::Proto::Token
    load_token? || raise Adgen::NotAuthorized.new("no tokens (#{token_path})")
  end

  private def authorize!
    client = config.adgen_client
    token = client.authorize!(config.api_email, config.api_password)
    save_token(token)
    return token
  end

  private def load_authorized_client
    client = config.adgen_client
    client.auth = active_token.value
    return client
  end  

  private def authorized_client
    load_authorized_client
  rescue Adgen::NotAuthorized
    authorize!
    load_authorized_client
  end
end
