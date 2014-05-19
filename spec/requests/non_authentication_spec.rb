require "spec_helper"

describe "Authentication" do
  include RestApiSpecHelper

  describe "GET /ping" do
    context "without any access token candidate" do
      before do
        header["Authorization"] = nil
      end

      it "does not check access token" do
        should == 200
        response.body.should be_json
      end

      it "returns valid data" do
        should == 200
        response.body.should be_json_as(message: "Pong")
      end
    end
  end
end
