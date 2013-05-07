require 'spec_helper'

describe "HATEOAS" do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user).token }

  before {
    with_access_token_header token
  }

  context "with test link href" do
    before { get "/users/#{user.id}" }
    subject { body['_links']['self']['href'] }

    it { should_not match /\?scheme=http/ }
    it { should_not match %r[^http://] }
    it { should match %r[^/] }
  end

  it "should follow uri and link@self" do
    get "/users/#{user.id}"

    @body = body
    follow_link 'self'
    body.should == @body
    follow_link 'self'
    body.should == @body

    create(:post, :user => user)

    follow_link 'posts'
    body.should have(1).items

    follow_link 'self', body[0]
    status.should == 200
    body.should_not be_nil
    body['_links'].should have_key 'self'
  end

  it 'follows rel="canonical"' do
    get "/users/#{user.id}"
    @body = body
    follow_link 'canonical'
    body.should == @body
  end
end
