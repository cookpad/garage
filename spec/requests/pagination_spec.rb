require 'spec_helper'

describe 'Request to /posts' do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user).token }

  before {
    with_access_token_header token
  }

  context 'when there is no post' do
    it "returns empty set of posts" do
      get "/posts"
      body.should be_empty
    end
  end

  context 'when there is one post' do
    it "returns one post" do
      post = create(:post, :user => user)
      get "/posts"
      body.should have(1).item
      body.first['id'].should == post.id
      link_for('next').should be_nil
    end
  end

  context 'when there are more than 20 posts' do
    before do
      21.times do
        create(:post, :user => user)
      end
    end

    it "paginates posts" do
      get "/posts"
      body.should have(20).items
      page_for('next').should == 2
      page_for('last').should == 2
    end

    it "paginates posts with page numbers" do
      get "/posts"
      LinkHeader.parse(response_header('Link')).find_link(["rel", "next"])['page'].should == "2"
    end

    it "paginates entries with per_page" do
      get "/posts?per_page=10"
      body.should have(10).items
      page_for('next').should == 2
      page_for('last').should == 3
      page_for('first').should be_nil
      page_for('prev').should be_nil
      link_for('next')[:per_page].should == "10"
    end

    it "does not disclose 'last' in /posts/hide" do
      get '/posts/hide'
      body.should have(20).items
      page_for('next').should == 2
      page_for('last').should be_nil
      page_for('first').should be_nil
      page_for('prev').should be_nil
    end

    it "displays prev and first" do
      get '/posts?page=2'
      body.should have(1).item
      page_for('next').should be_nil
      page_for('last').should be_nil
      page_for('first').should == 1
      page_for('prev').should == 1
    end

    it 'has an absolute path' do
      get '/posts'
      link = LinkHeader.parse(response_header('Link')).find_link(['rel', 'next'])
      link.href[0].should == '/'
    end

    it 'has correct pagination links' do
      get '/posts'
      link = LinkHeader.parse(response_header('Link')).find_link(['rel', 'next'])
      URI.parse(link.href).path.should == '/posts'
    end

    it "displays next, prev, last and first" do
      get "/posts?page=2&per_page=10"
      body.should have(10).items
      page_for('next').should == 3
      page_for('last').should == 3
      page_for('first').should == 1
      page_for('prev').should == 1
    end

    it "includes total count" do
      get "/posts"
      response_header('X-List-TotalCount').should == '21'
    end

    it 'hides total count on /posts' do
      get '/posts/hide'
      response_header('X-List-TotalCount').should be_nil
    end

    it 'hides total count on /capped' do
      get '/posts/capped'
      response_header('X-List-TotalCount').should be_nil
    end

    it 'does not have access_token header in the Link header' do
      get "/posts?access_token=#{token}"
      link = LinkHeader.parse(response_header('Link')).find_link(['rel', 'next'])
      link.href.should_not match /access_token=/
    end
  end

  context 'where there are 200 posts' do
    before do
      200.times do
        create(:post, user: user)
      end
    end

    it "cap the pagination at 100" do
      get '/posts/capped'
      body.should have(20).items
      page_for('next').should == 2
      page_for('last').should be_nil
      page_for('first').should be_nil
      page_for('prev').should be_nil
    end

    it "cap the pagination at 100" do
      get '/posts/capped?page=5'
      body.should have(20).items
      page_for('next').should be_nil
      page_for('last').should be_nil
      page_for('first').should == 1
      page_for('prev').should == 4
    end

    it "cap the pagination at 100" do
      get '/posts/capped?page=6'
      body.should be_empty
      page_for('next').should be_nil
    end

    it "cap the pagination at 100" do
      get '/posts/capped?page=7&per_page=15'
      body.should have(10).items
      page_for('next').should be_nil
    end

    it 'does not allow per_page > 100' do
      get "/posts?page=1&per_page=200"
      body.should_not have(200).items
      body.should have(100).items
    end
  end
end
