class Adgen::Config < TOML::Config
  class Error < Exception; end

  var clue : String

  # base
  bool "verbose"
  bool "dryrun"
  bool "colorize"
  int  "limit"
  str  "fields"
  str  "format"

  # api
  str  "api/token_path"
  str  "api/email"
  str  "api/password"
  bool "api/logging"
  str  "api/url"
  int  "api/keep_remaining"

  float "api/dns_timeout"
  float "api/connect_timeout"
  float "api/read_timeout"

  # batch
  str  "batch/work_dir"
  str  "batch/global_dir"
  str  "batch/status_log"
  int  "batch/max_attempts"
  bool "batch/skip_400"
  bool "batch/gc"
  bool "batch/pb_logging"

  # clickhouse
  str "clickhouse/host"
  int "clickhouse/port"
  str "clickhouse/db"
  str "clickhouse/table"
  
  var enabled_recvs : Set(String) = build_enabled_recvs

  def api_cmd?(model) : String?
    self.str?("#{model}/cmd")
  end

  def adgen_client : Adgen::Client
    client = Adgen::Client.new(host: api_url)
    strategy = Adgen::Strategy::Libcurl.new
    {% for x in %w( dns_timeout connect_timeout read_timeout ) %}
      strategy.{{x.id}} = api_{{x.id}}?
    {% end %}
    client.strategy = strategy

    client.dryrun! if dryrun?
    client
  end

  def batch_publisher_ids : Array(Int32)
    ints("batch/publisher_ids")
  end

  private def build_enabled_recvs
    set = Set(String).new
    toml["batch"].as(Hash).each do |k,v|
      if v && (k =~ /^recv_(.*?)$/)
        set << $1
      end
    end
    set
  end

  # callback for initialize
  def init!
  end

  def build_logger(path : String?) : Logger
    build_logger(self.toml["logger"]?, path)
  end

  def build_logger(hash, _path : String?) : Logger
    case hash
    when Nil
      return Logger.new(nil)
    when Array
      CompositeLogger.new(hash.map{|i| build_logger(i, _path).as(Logger)})
    when Hash
      hint = hash["name"]?.try{|s| "[#{s}]"} || ""
      hash["path"] ||= _path || raise Error.new("logger.path is missing")
      logger = CompositeLogger.build_logger(hash)
      logger.formatter = "{{mark}},[{{time=%H:%M}}] #{hint}{{message}}"
      return logger
    else
      raise Error.new("logger type error (#{hash.class})")
    end
  end

  def build_batch_status_logger?
    if path = batch_status_log?
      Dir.mkdir_p(File.dirname(path))
      opts = {
        "path"   => path,
        "mode"   => "a+",
        "level"  => "INFO",
        "format" => "{{mark}},[{{time=%H:%M}}] {{message}}",
      }
      return CompositeLogger.new(CompositeLogger.build_logger(opts))
    else
      return nil
    end    
  end

  def to_s(io : IO)
    max = @paths.keys.map(&.size).max
    @paths.each do |(key, val)|
      io.puts "  %-#{max}s = %s" % [key, val]
    end
  end

  private def pretty_dump(io : IO = STDERR)
    io.puts "[config] #{clue?}"
    io.puts to_s
  end
end

class Adgen::Config < TOML::Config
  def self.parse_file(path : String)
    super(path).tap(&.clue = path)
  end

  def self.empty
    parse("")
  end

  @@current : Adgen::Config = empty
  def self.current : Adgen::Config
    @@current
  end

  def self.current=(v) : Adgen::Config
    @@current = v
  end

  def self.sample
    parse(SAMPLE)
  end
end

Adgen::Config::SAMPLE = <<-EOF
[api]
token_path = "token.pb"
email      = ""
password   = ""

url             = "https://bigman-test.scaleout.jp"
logging         = true

dns_timeout     = 3.0
connect_timeout = 5.0
read_timeout    = 300.0

[batch]
publisher_ids   = [3]
work_dir        = "recv"
global_dir      = "global"
status_log      = "log"
gc              = true
pb_logging      = false
max_attempts    = 5
skip_400        = true

# main models
recv_native_pure_ad = true

[clickhouse]
host  = "localhost"
port  = 9000
db    = "adgen"

[[logger]]
progname = "adgen"
level    = "DEBUG"

[[logger]]
path     = "STDOUT"
level    = "=INFO"
colorize = true

[[logger]]
path     = "STDERR"
level    = ">=WARN"
colorize = true

[native_pure_ad]
cmd = "/api/v2/marketech/native_pure_ads -d publisher_id={PUBLISHER_ID}"
EOF
