require "spec_helper"

describe "Field loading API" do
  include RestApiSpecHelper
  include AuthenticatedContext

  let(:post) do
    FactoryGirl.create(:post)
  end

  describe "GET /posts/:id" do
    let(:id) do
      post.id
    end

    let!(:comment) do
      FactoryGirl.create(:comment, user: user, post: post)
    end

    context "with params[:fields] = nil" do
      it "returns default fields" do
        should == 200
        response.body.should be_json_as(
          id: Fixnum,
          title: String,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = '__default__,user'" do
      before do
        params[:fields] = "__default__,user"
      end

      it "returns default and user fields" do
        should == 200
        response.body.should be_json_as(
          id: Fixnum,
          title: String,
          user: Hash,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = '*'" do
      before do
        params[:fields] = "*"
      end

      it "returns all fields" do
        should == 200
        response.body.should be_json_as(
          id: Fixnum,
          title: String,
          user: Hash,
          comments: Array,
          _links: Hash,
        )
      end
    end

    context "with params[:fields] = 'id'" do
      before do
        params[:fields] = "id"
      end

      it "returns only id field" do
        should == 200
        response.body.should be_json_as(id: Fixnum)
      end
    end

    context "with params[:fields] = 'id,title'" do
      before do
        params[:fields] = "id,title"
      end

      it "returns only id and title fields" do
        should == 200
        response.body.should be_json_as(id: Fixnum, title: String)
      end
    end

    context "with params[:fields] = 'user[id]'" do
      before do
        params[:fields] = "user[id]"
      end

      it "returns only user's id field" do
        should == 200
        response.body.should be_json_as(
          user: {
            id: Fixnum,
          },
        )
      end
    end

    context "with params[:fields] = 'comments[__default__,post_owner]'" do
      before do
        params[:fields] = "comments[__default__,post_owner]"
      end

      it "returns only comments default & post_owner fields" do
        should == 200
        response.body.should be_json_as(
          comments: [
            {
              id: Fixnum,
              body: String,
              commenter: Hash,
              post_owner: Hash,
            },
          ],
        )
      end
    end

    context "with params[:fields] = 'comments[*]'" do
      before do
        params[:fields] = "comments[*]"
      end

      it "returns only comments all fields" do
        should == 200
        response.body.should be_json_as(
          comments: [
            {
              id: Fixnum,
              body: String,
              commenter: Hash,
              post_owner: Hash,
            },
          ],
        )
      end
    end

    context "with params[:fields] = 'comments[commenter[id]]'" do
      before do
        params[:fields] = "comments[commenter[id]]"
      end

      it "returns only comments commenter id field" do
        should == 200
        response.body.should be_json_as(
          comments: [
            {
              commenter: {
                id: Fixnum,
              },
            },
          ],
        )
      end
    end
  end

  describe "GET /users/:user_id/posts" do
    before do
      FactoryGirl.create(:post, user: user)
    end

    let(:user_id) do
      user.id
    end

    context "with caching" do
      it "caches response per params[:fields]" do
        should == 200
        response.body.should be_json_as([{ id: Fixnum, title: String, _links: Hash }])
        params[:fields] = "id"
        get path, params, env
        response.body.should be_json_as([{ id: Fixnum }])
      end
    end

    context "with invalid params[:fields]" do
      before do
        params[:fields] = "[]"
      end
      it { should == 400 }
    end
  end
end
