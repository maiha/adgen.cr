require "../dryrun"

module Adgen::Strategy
  class Dryrun < Base
    def execute(req : Request) : Response
      raise Adgen::Dryrun.new(req)
    end
  end
end
