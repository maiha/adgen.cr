{% begin %}
@[Link("curl", ldflags: "`command -v pkg-config > /dev/null && pkg-config --libs --silence-errors {{ flag?(:static) ? "--static".id : "".id }} libcurl || printf %s '-lcurl'`")]
lib LibCurl
end
TARGET_TRIPLE = "{{`crystal -v | grep x86_64 | cut -d: -f2`.strip}}"
{% end %}

require "json"
require "http"
require "uri"

require "var"
require "pretty"
require "curl"

require "./proto/**"
require "./adgen/client"
