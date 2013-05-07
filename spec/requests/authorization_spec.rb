require 'spec_helper'

describe Garage do
  let(:application) { create(:application) }
  let(:alice) { create(:user) }
  let(:bob) { create(:user )}
  let(:post) { create(:post, user: alice, title: "Foo") }
  let(:token) { client_is_authorized(application, requester).token }

  before do
    with_access_token_header token
  end

  describe 'GET request to post' do
    subject {
      get "/posts/#{post.id}"
      status
    }

    context 'with alice as a requester' do
      let(:requester) { alice }
      it 'returns 200' do
        subject.should == 200
      end
    end

    context 'with bob as a requester' do
      let(:requester) { bob }
      it 'returns 200' do
        subject.should == 200
      end
    end
  end

  describe 'PUT request to post' do
    subject {
      put "/posts/#{post.id}", :title => "Bar"
      status
    }


    context 'with alice as a requester' do
      let(:requester) { alice }
      it 'returns 204' do
        subject.should == 204
        post.reload.title.should == "Bar"
      end
    end

    context 'with bob as a requester' do
      let(:requester) { bob }
      it 'returns 403' do
        subject.should == 403
        post.reload.title.should == "Foo"
      end
    end
  end
end
