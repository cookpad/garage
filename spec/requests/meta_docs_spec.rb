require "spec_helper"

describe "Meta Docs" do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:scopes) do
    "public meta"
  end

  describe "GET /meta/docs" do
    context "without valid access token" do
      before do
        header.delete("Authorization")
      end
      it { is_expected.to eq(401) }
    end

    context "without meta scope" do
      let(:scopes) do
        "public"
      end
      it { is_expected.to eq(403) }
    end

    context "with valid condition" do
      it "returns meta resources about documentation" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as(
          [
            {
              name: "post",
              toc: String,
              rendered_body: String,
            },
            {
              name: "site_admin-admin_user",
              toc: String,
              rendered_body: String,
            },
            {
              name: "user",
              toc: String,
              rendered_body: String,
            },
          ],
        )
      end
    end
  end
end
