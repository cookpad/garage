require "spec_helper"

describe "Meta Services" do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:scopes) do
    "public meta"
  end

  describe "GET /meta/services" do
    context "without valid scope" do
      let(:scopes) do
        "public"
      end
      it { should == 403 }
    end

    context "with valid condition" do
      it "returns services" do
        should == 200
        response.body.should be_json_as([Hash, Hash])
      end
    end
  end
end
