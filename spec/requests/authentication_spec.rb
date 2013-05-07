require 'spec_helper'

describe Garage do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user) }

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

    context 'with bad token' do
      let(:token_value) { nil }
      it 'returns 401' do
        subject.should == 401
      end
    end

    context 'with an authorized token' do
      let(:token_value) { token.token }
      it 'returns 200' do
        subject.should == 200
      end
    end
  end
end
