require "spec_helper"

describe "Authentication" do
  include RestApiSpecHelper

  describe "GET /echo" do
    context "with 401 from auth server" do
      before do
        stub_request(:get, Garage.configuration.auth_center_url).to_return(status: 401)
      end

      it "returns 401 with JSON" do
        should == 401
        response.body.should be_json
      end
    end

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
      before do
        header["Authorization"] = "Bearer #{SecureRandom.hex(32)}"
        stub_access_token_request
      end
      it { should == 200 }
    end
  end
end
