require "spec_helper"

describe "Authentication" do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /echo" do
    context "without Authorization header" do
      before do
        header["Authorization"] = nil
      end

      it "returns 401 with JSON" do
        should == 401
        response.body.should be_json
      end
    end

    context "with non existent access token" do
      before do
        header["Authorization"] = "Bearer #{SecureRandom.hex(32)}"
      end
      it { should == 401 }
    end
  end
end
