require 'spec_helper'

describe Garage do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user) }

  describe 'HTTP request' do
    context 'without any token' do
      it 'returns 401' do
        get '/echo'
        status.should == 401
      end
    end

    context 'with an authorized token' do
      before do
        with_access_token_header token.token
      end

      it 'returns 200' do
        get '/echo'
        status.should == 200
      end
    end
  end
end
