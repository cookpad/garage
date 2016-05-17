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
        is_expected.to eq(401)
        expect(response.body).to be_json
      end
    end

    context "with valid access token from auth server" do
      it { is_expected.to eq(200) }
    end
  end
end
