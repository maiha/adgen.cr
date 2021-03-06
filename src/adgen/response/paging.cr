class Adgen::Response
  class Paging

    # "paging": {
    #   "cursors": {
    #     "before": "NjAwMjkxMjcyOTczMQZDZD",
    #     "after": "NjAwMjkxMjcyOTczMQZDZD"
    #   },
    #   "next": "https://graph.adgen.com/..."

    class Cursors
      JSON.mapping({
        before: String?,
        after: String?,
      })
    end

    JSON.mapping({
      cursors: Cursors?,
      next: String?,
      previous: String?,
    })
  end
end
