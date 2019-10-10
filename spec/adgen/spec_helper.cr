require "spec"
require "../../src/adgen"

def read_mock(file : String)
  File.read(File.join(__DIR__, "mock", file))
end
