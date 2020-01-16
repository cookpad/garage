require "spec_helper"

describe "Docs", type: :request do
  include RestApiSpecHelper

  before do
    header.delete("Accept")
    Garage.configuration.docs.console_app_uid = application_uid
  end

  after do
    Garage.configuration.docs.console_app_uid = nil
  end

  let(:application_uid) do
    SecureRandom.uuid
  end

  let!(:post_a) do
    FactoryBot.create(:post)
  end

  describe "GET /docs/resources/post" do
    it "returns response with a link to the post example" do
      is_expected.to eq(200)
      expect(response.body).to include "location=%2Fposts%2F#{post_a.id}"
    end

    it "returns response with a title" do
      is_expected.to eq(200)
      expect(response.body).to include "<title>Post API - Garage</title>"
    end
  end

  describe "GET /docs/resources" do
    context "with valid condition" do
      it "returns default overview page" do
        is_expected.to eq(200)
        expect(response.body).to include "This is overview"
      end
    end

    context "with params[:lang] = 'ja'" do
      before do
        params[:lang] = "ja"
      end

      it "returns Japanese overview page" do
        is_expected.to eq(200)
        expect(response.body).to include "Japanese page"
      end
    end

    context "with header['Accept-Language'] = 'ja'" do
      before do
        header["Accept-Language"] = "ja"
      end

      it "returns Japanese overview page" do
        is_expected.to eq(200)
        expect(response.body).to include "Japanese page"
      end
    end

    context "with header['Accept-Language'] = 'unsupported'" do
      before do
        header["Accept-Language"] = "unsupported"
      end

      it "returns default overview page" do
        is_expected.to eq(200)
        expect(response.body).to include "This is overview"
      end
    end

    context 'with default singnout path' do
      let(:user) { FactoryBot.create(:user) }

      before do
        post session_path, { user: { name: user.name } }
      end

      it "shows customized signout link" do
        is_expected.to eq(200)
        expect(response.body).to include '<a rel="nofollow" data-method="post" href="/signout">Signout</a>'
      end
    end

    context 'with custom singnout path' do
      let(:user) { FactoryBot.create(:user) }

      before do
        allow(Garage.configuration.docs).to receive(:signout_path).and_return('/session/logout')
        allow(Garage.configuration.docs).to receive(:signout_request_method).and_return(:get)
        post session_path, { user: { name: user.name } }
      end

      it "shows customized signout link" do
        is_expected.to eq(200)
        expect(response.body).to include '<a data-method="get" href="/session/logout">Signout</a>'
      end
    end
  end
end
