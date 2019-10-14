require "./strategy/*"

module Adgen::Strategy
  var strategy : Strategy::Base

  # overrides to bind logger
  def strategy=(v : Strategy::Base)
    @strategy = v
    strategy.logger = logger
  end

  def execute(*args, **opts)
    req = request(*args, **opts)
    execute(req)
  end

  def execute(req : Request) : Response
    before_validate.each &.call(req)
    validate(req)

    before_execute.each &.call(req)
    res = strategy.execute(req)
    return res
  rescue except : Adgen::Dryrun | Adgen::Auth::NotAuthorizedError
    raise except
  rescue cause
    raise Api::Error.new(req, res, cause)
  ensure
    after_execute.each(&.call(req, res))
  end
end
