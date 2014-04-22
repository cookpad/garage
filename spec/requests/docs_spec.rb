require "spec_helper"

describe "Docs" do
  include RestApiSpecHelper

  before do
    header.delete("Accept")
    Garage.configuration.docs.console_app_uid = application.uid
  end

  after do
    Garage.configuration.docs.console_app_uid = nil
  end

  let(:application) do
    FactoryGirl.create(:application)
  end

  let!(:post) do
    FactoryGirl.create(:post)
  end

  describe "GET /docs/resources/post" do
    it "returns response with a link to the post example" do
      should == 200
      response.body.should include "location=%2Fposts%2F#{post.id}"
    end

    it "returns response with a title" do
      should == 200
      response.body.should include "<title>Post API - Garage</title>"
    end
  end

  describe "GET /docs/resources" do
    context "with valid condition" do
      it "returns default overview page" do
        should == 200
        response.body.should include "This is overview"
      end
    end

    context "with params[:lang] = 'ja'" do
      before do
        params[:lang] = "ja"
      end

      it "returns Japanese overview page" do
        should == 200
        response.body.should include "Japanese page"
      end
    end

    context "with header['Accept-Language'] = 'ja'" do
      before do
        header["Accept-Language"] = "ja"
      end

      it "returns Japanese overview page" do
        should == 200
        response.body.should include "Japanese page"
      end
    end

    context "with header['Accept-Language'] = 'unsupported'" do
      before do
        header["Accept-Language"] = "unsupported"
      end

      it "returns default overview page" do
        should == 200
        response.body.should include "This is overview"
      end
    end
  end
end
