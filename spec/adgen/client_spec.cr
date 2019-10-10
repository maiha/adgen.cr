require "./spec_helper"

describe Adgen::Client do
  describe "#request" do
    it "builds request object" do
      client = Adgen::Client.new(api: "/me")
      client.request.to_s.should eq("https://graph.adgen.com/me")
    end

    it "respects api" do
      client = Adgen::Client.new(api: "/v4.0/me")
      client.request.to_s.should eq("https://graph.adgen.com/v4.0/me")

      client = Adgen::Client.new
      client.api = Adgen::Api::Get.new("/me", data: {"limit" => "2"})
      client.request.to_s.should eq("https://graph.adgen.com/me?limit=2")

      client = Adgen::Client.new
      client.api = Adgen::Api::Get.parse("/me -d limit=3")
      client.request.to_s.should eq("https://graph.adgen.com/me?limit=3")
    end

    it "respects host" do
      client = Adgen::Client.new(api: "/me")
      client.host = "http://localhost:8080"
      client.request.to_s.should eq("http://localhost:8080/me")
    end
  end

  describe "#get" do
    context "('/foo -d a=1 -d b=2')" do
      it "accepts '-d' as data" do
        client = Adgen::Client.new(auth: "xxx")
        client.dryrun!

        expect_raises(Adgen::Dryrun, "curl -s -G -d 'a=1' -d 'b=2' -d 'token=xxx' https://graph.adgen.com/foo") do
          client.get("/foo -d a=1 -d b=2")
        end
      end
    end

    context "('/foo -d a=1 -d b=2', {a=>x})" do
      it "overwrites data by parameters" do
        client = Adgen::Client.new(auth: "xxx")
        client.dryrun!

        expect_raises(Adgen::Dryrun, "curl -s -G -d 'a=x' -d 'b=2' -d 'token=xxx' https://graph.adgen.com/foo") do
          client.get("/foo -d a=1 -d b=2", {"a" => "x"})
        end
      end
    end
  end
  
  describe "#execute" do
    it "raises when auth is not set or empty" do
      client = Adgen::Client.new(api: "/me")
      expect_raises(Adgen::Auth::NotAuthorizedError) do
        client.execute
      end

      client.auth = ""
      expect_raises(Adgen::Auth::NotAuthorizedError) do
        client.execute
      end
    end

    it "raises Dryrun when the strategy is dryrun" do
      client = Adgen::Client.new(api: "/me")
      client.auth = "xxx"
      client.dryrun!

      expect_raises(Adgen::Dryrun, "curl -s -G -d 'token=xxx' https://graph.adgen.com/me") do
        client.execute
      end
    end

    context "(http connection error)" do
      it "raises with connection info" do
        client = Adgen::Client.new(api: "/me", auth: "xxx")
        client.host = "http://localhost:4"

        expect_raises(Exception, "Failed to connect localhost port 4") do
          client.execute
        end
      end
    end
  end
end
