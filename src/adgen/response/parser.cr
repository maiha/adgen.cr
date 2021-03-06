require "./error"
require "./paging"

class Adgen::Response
  class Parser(T)
    include Enumerable(T)
    
    var res : Response

    # "data": [{...}, {...}, ...],
    # "paging": {
    #   "cursors": {
    #     "before": "NjAwMjkxMjcyOTczMQZDZD",
    #     "after": "NjAwMjkxMjcyOTczMQZDZD"
    #   },
    #   "next": "https://graph.adgen.com/..."
    JSON.mapping({
      data: Array(T)?,
      paging: Paging?,
      error: Error?,
    })
    
    def initialize(@res)
    end

    def each : Nil
      if ary = data
        ary.each do |i|
          yield(i)
        end
      end
    end
  end
end
