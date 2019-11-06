class Cmds::BatchCmd
  class RetryableError < Exception
    def initialize(err)
      super(err.to_s, cause: err)
    end
  end
end
