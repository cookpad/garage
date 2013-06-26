require "spec_helper"

describe "Scope" do
  let(:application) do
    create(:application)
  end

  let(:user) do
    create(:user)
  end

  let(:post) do
    create(:post, user: user, body: "body")
  end

  let(:token) do
    client_is_authorized(application, user, scopes: scopes).token
  end

  before do
    with_access_token_header token
  end

  describe "GET /posts/:id" do
    context "without specified scope" do
      let(:scopes) do
        nil
      end

      it "excludes scoped field" do
        get "/posts/#{post.id}"
        body["body"].should == nil
      end
    end

    context "with specified scope" do
      let(:scopes) do
        "read_post_body"
      end

      it "includes scoped field" do
        get "/posts/#{post.id}"
        body["body"].should == "body"
      end
    end
  end
end
