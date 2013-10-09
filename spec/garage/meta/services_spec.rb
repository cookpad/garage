require 'spec_helper'

describe '/meta/services', type: :request do
  let(:application) { create(:application) }
  let(:token) { client_is_authorized(application, nil, scopes: 'meta').token }

  before do
    with_access_token_header token if token
  end

  context 'without token' do
    let(:token) { nil }
    it 'returns 401' do
      get '/meta/services'
      status.should == 401
    end
  end

  context 'with token not having "meta"' do
    let(:token) { client_is_authorized(application, nil, scopes: 'public').token }
    it 'returns 403' do
      get '/meta/services'
      body['error'].should match /Insufficient scope/
      status.should == 403
    end
  end

  context 'with token' do
    it 'returns 200' do
      get '/meta/services'
      status.should == 200
      body.should have(2).items
    end
  end
end
