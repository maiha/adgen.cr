# recoverable error (5xx)
class Adgen::Error < Exception
end

# fatal error (bug)
class Adgen::Fatal < Adgen::Error
end

# unrecoverable error (4xx)
class Adgen::Denied < Adgen::Fatal
end

# token errors
class Adgen::TokenError < Adgen::Denied
end

class Adgen::NotAuthorized < Adgen::TokenError
end

class Adgen::TokenExpired < Adgen::TokenError
end

