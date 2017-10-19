require "spec_helper"

describe "Pagination", type: :request do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /posts" do
    context "with no post" do
      it "returns no link header" do
        is_expected.to eq(200)
        expect(response.header["Link"]).to eq(nil)
      end
    end

    context "with one post" do
      before do
        FactoryGirl.create(:post)
      end

      it "returns current link header" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "1", per_page: "20" })
      end
    end

    context "with middle page" do
      before do
        6.times do
          FactoryGirl.create(:post)
        end
        params[:page] = 2
        params[:per_page] = 2
      end

      it "returns current, prev, first, next, and last link header" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "2", per_page: "2" })
        expect(link_for("first")).to eq({ page: "1", per_page: "2" })
        expect(link_for("prev")).to eq({ page: "1", per_page: "2" })
        expect(link_for("next")).to eq({ page: "3", per_page: "2" })
        expect(link_for("last")).to eq({ page: "3", per_page: "2" })
      end
    end

    context "with first page" do
      before do
        2.times do
          FactoryGirl.create(:post)
        end
        params[:page] = 1
        params[:per_page] = 1
      end

      it "returns current, next and lsat link header" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "1", per_page: "1" })
        expect(link_for("next")).to eq({ page: "2", per_page: "1" })
        expect(link_for("last")).to eq({ page: "2", per_page: "1" })
      end
    end

    context "with last page" do
      before do
        2.times do
          FactoryGirl.create(:post)
        end
        params[:page] = 2
        params[:per_page] = 1
      end

      it "returns current, prev and first link header" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "2", per_page: "1" })
        expect(link_for("first")).to eq({ page: "1", per_page: "1" })
        expect(link_for("prev")).to eq({ page: "1", per_page: "1" })
      end
    end

    context "with 2 posts" do
      before do
        2.times do
          FactoryGirl.create(:post)
        end
      end

      it "returns X-List-TotalCount header" do
        is_expected.to eq(200)
        expect(response.header["X-List-TotalCount"]).to eq("2")
      end
    end

    context "with params[:page] = 9999" do
      before do
        params[:page] = 9999
      end

      it "returns no posts" do
        is_expected.to eq(200)
        expect(response.body).to be_json_as([])
      end
    end

    context "with 200 posts & params[:per_page] = 200" do
      before do
        200.times do
          FactoryGirl.create(:post)
        end
        params[:per_page] = 200
      end

      it "returns up to 100 resources per page" do
        is_expected.to eq(200)
        expect(response.header["X-List-TotalCount"]).to eq("200")
        expect(response.body).to be_json_as(->(array) { array.size == 100 } )
      end
    end
  end

  describe "GET /posts/hide" do
    before do
      3.times do
        FactoryGirl.create(:post)
      end
      params[:per_page] = 1
    end

    context "with valid condition" do
      it "returns no X-List-TotalCount header" do
        is_expected.to eq(200)
        expect(response.header["X-List-TotalCount"]).to eq(nil)
      end
    end

    context "with middle page" do
      before do
        params[:page] = 2
      end

      it "returns current, links except for last" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "2", per_page: "1" })
        expect(link_for("first")).to eq({ page: "1", per_page: "1" })
        expect(link_for("prev")).to eq({ page: "1", per_page: "1" })
        expect(link_for("next")).to eq({ page: "3", per_page: "1" })
        expect(link_for("last")).to eq(nil)
      end
    end

    context "with last page" do
      before do
        params[:page] = 3
      end

      it "returns links except for last" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "3", per_page: "1" })
        expect(link_for("first")).to eq({ page: "1", per_page: "1" })
        expect(link_for("prev")).to eq({ page: "2", per_page: "1" })
        expect(link_for("next")).to eq({ page: "4", per_page: "1" })
        expect(link_for("last")).to eq(nil)
      end
    end
  end

  describe "GET /posts/capped" do
    context "with 200 posts" do
      before do
        200.times do
          FactoryGirl.create(:post)
        end
        params[:page] = 7
      end

      it "returns up to limited count" do
        is_expected.to eq(200)
        expect(response.header["X-List-TotalCount"]).to eq(nil)
        expect(response.body).to be_json([])
        expect(link_for("current")).to eq({ page: "7", per_page: "20" })
        expect(link_for("first")).to eq({ page: "1", per_page: "20" })
        expect(link_for("prev")).to eq({ page: "6", per_page: "20" })
        expect(link_for("next")).to eq(nil)
        expect(link_for("last")).to eq(nil)
      end
    end

    context "with hard limit option" do
      it "hides last link" do
        is_expected.to eq(200)
        expect(link_for("current")).to eq({ page: "1", per_page: "20" })
        expect(link_for("first")).to eq(nil)
        expect(link_for("prev")).to eq(nil)
        expect(link_for("next")).to eq({ page: "2", per_page: "20" })
        expect(link_for("last")).to eq(nil)
      end
    end
  end
end
