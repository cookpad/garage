require "spec_helper"

describe "Authentication" do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /echo" do
    context "without any access token candidate" do
      before do
        header["Authorization"] = nil
      end

      it "returns 401 without access token verification" do
        should == 401
        response.body.should be_json
      end
    end

    context "with valid access token from auth server" do
      it { should == 200 }
    end
  end
end
