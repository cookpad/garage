require "spec_helper"

describe "Authorization", type: :request do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:alice) do
    FactoryBot.create(:user)
  end

  let(:bob) do
    FactoryBot.create(:user)
  end

  let(:scopes) do
    "public read_private_post write_post sudo"
  end

  let(:resource_owner_id) do
    requester.id
  end

  let(:requester) do
    alice
  end

  let(:resource) do
    FactoryBot.create(:post, user: alice)
  end

  let(:id) do
    resource.id
  end

  describe "GET /users/:user_id/posts/private" do
    let(:user_id) do
      alice.id
    end

    context "without valid scope" do
      let(:scopes) do
        "public"
      end
      it { is_expected.to eq(403) }
    end

    context "without authority" do
      let(:requester) do
        bob
      end
      it { is_expected.to eq(403) }
    end

    context "with valid scope" do
      it { is_expected.to eq(200) }
    end

    context "with another valid scope" do
      let(:scopes) do
        "public sudo"
      end
      it { is_expected.to eq(200) }
    end
  end

  describe "GET /posts/:id" do
    let(:requester) do
      alice
    end

    context "with valid requester" do
      it { is_expected.to eq(200) }
    end

    context "with another valid requester" do
      let(:requester) do
        bob
      end
      it { is_expected.to eq(200) }
    end
  end

  describe "GET /posts" do
    context "with stream=1 & no valid scope" do
      before do
        params[:stream] = 1
      end

      let(:scopes) do
        "public"
      end

      it { is_expected.to eq(403) }
    end

    context "with stream=1 & valid scope" do
      it { is_expected.to eq(200) }
    end
  end

  describe "PUT /posts/:id" do
    before do
      params[:title] = "Bar"
    end

    context "with invalid requester" do
      let(:requester) do
        bob
      end
      it { is_expected.to eq(403) }
    end

    context "with response body option" do
      it "returns 200 with response body" do
        is_expected.to eq(200)
        expect(response.body).to be_json_including(id: resource.id)
      end
    end
  end

  describe "POST /posts" do
    before do
      params[:title] = "test"
    end

    context "with valid condition" do
      it { is_expected.to eq(201) }
    end
  end

  describe "DELETE /posts/:id" do
    context "with response body option" do
      it "returns 200 with response body" do
        is_expected.to eq(200)
        expect(response.body).to be_json_including(id: resource.id)
      end
    end

    context "with invalid requester" do
      let(:requester) do
        bob
      end
      it { is_expected.to eq(403) }
    end
  end

  describe "GET /posts/namespaced" do
    let(:scopes) do
      "public foobar.read_post"
    end

    context "with valid condition" do
      it { is_expected.to eq(200) }
    end

    context "without valid scope" do
      let(:scopes) do
        "public"
      end
      it { is_expected.to eq(403) }
    end
  end

  describe "log notifications" do
    context "with 200 case" do
      it "logs application id" do
        get "/posts/#{id}", params, env
        expect(response.status).to eq(200)
        expect(response.headers["Application-Id"]).to eq(application_id)
      end
    end

    context "with 404 case" do
      let(:id) do
        0
      end

      it "logs application id" do
        get "/posts/#{id}", params, env
        expect(response.status).to eq(404)
        expect(response.headers["Application-Id"]).to eq(application_id)
      end
    end

    context "with 401 case" do
      before do
        header.delete("Authorization")
      end

      it "logs application id" do
        get "/posts/#{id}", params, env
        expect(response.status).to eq(401)
        expect(response.headers["Application-Id"]).to eq(nil)
      end
    end
  end
end
