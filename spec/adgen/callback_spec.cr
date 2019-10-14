require "./spec_helper"

describe Adgen::Callback do
  describe "#after_execute" do
    it "should be invoked even if raises an error" do
      client = Adgen::Client.new(auth: "xxx")
      client.host = "http://localhost:4" # should raise error

      callbacks = Array(String).new
      client.before_validate{|i| callbacks << "before_validate"}
      client.before_execute {|i| callbacks << "before_execute" }
      client.after_execute  {|i| callbacks << "after_execute" }

      expect_raises(Adgen::Api::Error) {client.get("/me")}
      callbacks.should eq(["before_validate", "before_execute", "after_execute"])
    end
  end
end
