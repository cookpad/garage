require "spec_helper"

describe "Pagination" do
  include RestApiSpecHelper
  include AuthenticatedContext

  describe "GET /posts" do
    context "with no post" do
      it "returns no link header" do
        should == 200
        response.header["Link"].should == nil
      end
    end

    context "with one post" do
      before do
        FactoryGirl.create(:post)
      end

      it "returns no link header" do
        should == 200
        response.header["Link"].should == nil
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

      it "returns prev, first, next, and last link header" do
        should == 200
        link_for("first").should == { page: "1", per_page: "2" }
        link_for("prev").should == { page: "1", per_page: "2" }
        link_for("next").should == { page: "3", per_page: "2" }
        link_for("last").should == { page: "3", per_page: "2" }
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

      it "returns next and lsat link header" do
        should == 200
        link_for("next").should == { page: "2", per_page: "1" }
        link_for("last").should == { page: "2", per_page: "1" }
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

      it "returns prev and first link header" do
        should == 200
        link_for("first").should == { page: "1", per_page: "1" }
        link_for("prev").should == { page: "1", per_page: "1" }
      end
    end

    context "with 2 posts" do
      before do
        2.times do
          FactoryGirl.create(:post)
        end
      end

      it "returns X-List-TotalCount header" do
        should == 200
        response.header["X-List-TotalCount"].should == "2"
      end
    end

    context "with params[:page] = 9999" do
      before do
        params[:page] = 9999
      end

      it "returns no posts" do
        should == 200
        response.body.should be_json_as([])
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
        should == 200
        response.header["X-List-TotalCount"].should == "200"
        response.body.should be_json_as(->(array) { array.size == 100 } )
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
        should == 200
        response.header["X-List-TotalCount"].should == nil
      end
    end

    context "with middle page" do
      before do
        params[:page] = 2
      end

      it "returns links except for last" do
        should == 200
        link_for("first").should == { page: "1", per_page: "1" }
        link_for("prev").should == { page: "1", per_page: "1" }
        link_for("next").should == { page: "3", per_page: "1" }
        link_for("last").should == nil
      end
    end

    context "with last page" do
      before do
        params[:page] = 3
      end

      it "returns links except for last" do
        should == 200
        link_for("first").should == { page: "1", per_page: "1" }
        link_for("prev").should == { page: "2", per_page: "1" }
        link_for("next").should == { page: "4", per_page: "1" }
        link_for("last").should == nil
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
        should == 200
        response.header["X-List-TotalCount"].should == nil
        response.body.should be_json([])
        link_for("first").should == { page: "1", per_page: "20" }
        link_for("prev").should == { page: "6", per_page: "20" }
        link_for("next").should == nil
        link_for("last").should == nil
      end
    end

    context "with hard limit option" do
      it "hides last link" do
        should == 200
        link_for("first").should == nil
        link_for("prev").should == nil
        link_for("next").should == { page: "2", per_page: "20" }
        link_for("last").should == nil
      end
    end
  end
end
