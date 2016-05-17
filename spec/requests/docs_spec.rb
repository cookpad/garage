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
    FactoryGirl.create(:post)
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
  end
end
