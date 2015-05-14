require 'spec_helper'

RSpec.describe Garage::AuthenticationStrategy::AuthServer do
  before do
    allow(Garage.configuration).to receive(:auth_server_url).and_return(auth_server_url)
  end

  let(:auth_server_url) { 'http://example.com/token' }

  describe 'AccessTokenFetcher.fetch' do
    let(:fetcher) { Garage::AuthenticationStrategy::AuthServer::AccessTokenFetcher }
    let(:request) { double(:request, authorization: requested_token) }
    let(:requested_token) { 'dummy_token' }

    context 'when authorization succeed' do
      let(:response_json) { response.to_json }
      let(:response) do
        {
          token: requested_token,
          token_type: 'bearer',
          scope: 'public read_user',
          application_id: 1,
          resource_owner_id: 1,
          expired_at: 1.minute.since,
          revoked_at: nil,
        }
      end

      before do
        stub_request(:get, auth_server_url).to_return(status: 200, body: response_json)
      end

      it 'returns valid access token' do
        token = fetcher.fetch(request)
        expect(token).to be_accessible
      end
    end

    context 'when authorization failed' do
      let(:response_json) { {}.to_json }

      before do
        stub_request(:get, auth_server_url).to_return(status: 401, body: response_json)
      end

      it 'returns nil' do
        token = fetcher.fetch(request)
        expect(token).to be_nil
      end
    end

    context 'when requested token is empty' do
      let(:requested_token) { nil }

      it 'does not request to auth server then returns nil' do
        token = fetcher.fetch(request)
        expect(token).to be_nil
      end
    end
  end
end
