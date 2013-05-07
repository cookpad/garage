require 'spec_helper'

describe Garage do
  let(:application) { create(:application) }
  let(:user) { create(:user) }

  describe 'HTTP request' do
    before do
      with_access_token_header token_value if token_value
      get '/echo'
    end

    subject { status }

    context 'without any token' do
      let(:token_value) { nil }
      it 'returns 401' do
        subject.should == 401
      end
    end

    context 'with a bad token' do
      let(:token_value) { nil }
      it 'returns 401' do
        subject.should == 401
      end
    end

    context 'with a user-authenticated token' do
      let(:token_value) { client_is_authorized(application, user).token }
      it 'returns 200' do
        subject.should == 200
      end
    end

    context 'with client-authenticated token' do
      let(:token_value) { client_is_authorized(application, nil).token }
      it 'returns 200' do
        subject.should == 200
      end
    end
  end

  describe 'HTTP request' do
    before do
      with_access_token_header token_value if token_value
      get '/oauth/token/info'
    end

    context 'without any token' do
      let(:token_value) { nil }
      it 'returns 401' do
        status.should == 401
      end
    end

    context 'with a user-authenticated token' do
      let(:token_value) { client_is_authorized(application, user).token }
      it 'returns resource-owner-id' do
        body['resource_owner_id'].should == user.id
        body['application']['uid'].should == application.uid
      end
    end

    context 'with client-authenticated token' do
      let(:token_value) { client_is_authorized(application, nil).token }
      it 'returns no resource-owner-id' do
        body['resource_owner_id'].should be_nil
        body['application']['uid'].should == application.uid
      end
    end
  end
end
