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
      it { is_expected.to eq(403) }
    end

    context "with valid condition" do
      it "returns services" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as([Hash, Hash])
      end
    end
  end
end
