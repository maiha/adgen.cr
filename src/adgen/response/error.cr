class Adgen::Response
  class Error < Exception
    var res : Adgen::Response
    var max_bytes = 120

    delegate code, body, req, to: res
    
    def initialize(@res)
    end
    
    def message : String
      case res.media_type?
      when "text/html"
        v = extract_message_from_html
      when "application/json"
        v = extract_message_from_text
      else
        v = extract_message_from_text
      end
      return v.strip
    end

    private def strip_html_tag(html)
      html.gsub(/<.*?>/, " ").gsub(/\s+/, " ")
    end
    
    private def extract_message_from_html
      all = strip_html_tag(body)
      if all.bytesize <= max_bytes
        return all
      end

      # "<html><body><h1>503 Service Unavailable</h1>\nNo server is available to handle this request.\n</body></html>\n"
      case body
      when %r{<h1>(.*?)</h1>}mi
        v = $1
      else
        v = all
      end
      return v
    end

    private def extract_message_from_json
      raise NotImplementedError.new("#{self.class}#extract_message_from_json")
    end
    
    private def extract_message_from_text
      body.split(//)[0..max_bytes-1].join
    end
    
    def to_s(io : IO)
      io << "%s: %s (%s)" % [code, message, req.safe_url]
    end
  end
end
