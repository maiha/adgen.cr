Cmds.command "api" do
  include ::Cli::Helpers::Token

  var client = config.adgen_client

  delegate verbose?, to: config

  def before
    self.logger = Logger.new(nil)
  end
  
  usage "token # show current token"
  task "token" do
    puts active_token
  end

  usage "authorize # get new token"
  task "authorize" do
    token = authorize!
    puts token
  end

  usage "native_pure_ads PUBLISHER_ID # native_pure_ads 3"
  task native_pure_ads, "3" do
    path = "/api/v2/marketech/native_pure_ads?publisher_id=#{arg1}"
    client = authorized_client
    res = client.get(path)
    show(res)
  end
  
  usage "get XXX # get 'XXX' as is"
  task get, "XXX" do
    client = authorized_client
    res = client.get(arg1)
    show(res)
  end

  usage "data XXX # call 'GET XXX', then extract data as json"
  task data, "XXX" do
    if limit = config.limit?
      res = client.get(arg1, {"limit" => limit.to_s})
    else
      res = client.get(arg1)
    end
    json = JSON::Parser.new(res.body).parse
    data = json["data"]? || abort "res[data] not found"
    puts data.to_json
  end

  private def show_headers(res : Adgen::Response)
    hash = res.headers.to_h
    lines = Array(Array(String)).new
    hash.each do |k,v|
      lines << [k.to_s, v.inspect]
    end
    puts Pretty.lines(lines, delimiter: " ").split(/\n/).map(&.gsub(/\s+$/,"")).join("\n")
  rescue Adgen::Api::Error
    puts "N/A"
  rescue err
    puts "!!!!!!!!!!! #{err} !!!!!!!!!!!!"
    puts res.header
  end

  private def show_body(res : Adgen::Response)
    puts Pretty.json(res.body, color: config.colorize?)
  rescue Adgen::Api::Error
    puts "N/A"
  rescue
    puts res.body
  end

  private def show(res : Adgen::Response)
    if verbose?
      puts "%s %s %s" % [res.code, res.req.api.method, res.req.url]
      puts "----------------------------------------"
      show_headers(res)
      puts "----------------------------------------"
    end
    show_body(res)
  end
end
