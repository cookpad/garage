require 'spec_helper'

RSpec.describe Garage::Strategy::AuthServer do
  before do
    allow(Garage.configuration).to receive(:auth_server_url).and_return(auth_server_url)
  end

  let(:auth_server_url) { 'http://example.com/token' }
  let(:request) { double(:request, authorization: authorization, params: {}, headers: {}) }
  let(:authorization) { "Bearer #{requested_token}" }
  let(:requested_token) { 'dummy_token' }
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

  describe Garage::Strategy::AuthServer::AccessTokenFetcher do
    let(:fetcher) { Garage::Strategy::AuthServer::AccessTokenFetcher }

    describe '.fetch' do
      context 'when authorization succeed' do
        before do
          stub_request(:get, auth_server_url).to_return(status: 200, body: response.to_json)
        end

        it 'returns valid access token' do
          token = fetcher.fetch(request)
          expect(token).to be_accessible
        end
      end

      context 'when authorization failed' do
        let(:response) { {} }

        before do
          stub_request(:get, auth_server_url).to_return(status: 401, body: response.to_json)
        end

        it 'returns nil' do
          token = fetcher.fetch(request)
          expect(token).to be_nil
        end
      end

      context 'when auth server responds an error' do
        before do
          stub_request(:get, auth_server_url).to_return(status: 500, body: { error: 'unexpected_error' }.to_json)
        end

        it 'raises Garage::AuthBackendError' do
          expect { fetcher.fetch(request) }.to raise_error(Garage::AuthBackendError)
        end
      end

      context 'when the request to auth server timed out' do
        before do
          stub_request(:get, auth_server_url).to_timeout
        end

        it 'raises Garage::AuthBackendTimeout' do
          expect { fetcher.fetch(request) }.to raise_error(Garage::AuthBackendTimeout)
        end
      end

      context 'when requested token is empty' do
        let(:authorization) { nil }

        it 'does not request to auth server then returns nil' do
          token = fetcher.fetch(request)
          expect(token).to be_nil
        end
      end
    end

    describe '.fetch with caching' do
      let(:cache_key) { "garage_gem/token_cache/#{Garage::VERSION}/#{requested_token}" }

      before do
        allow(Garage.configuration).to receive(:cache_acceess_token_validation?).and_return(true)
        Rails.cache.clear
      end
      after { Rails.cache.clear }

      context 'with bearer token on authorization header' do
        context 'when cache hits' do
          let(:access_token) { double(:access_token, expired?: false) }

          it 'reads cache then return cache' do
            expect(Rails.cache).to receive(:read).
              with(cache_key).
              and_return(access_token)
            expect(fetcher.fetch(request)).to eq(access_token)
          end
        end

        context 'when cache does not hit' do
          it 'reads cache then requests access_token then writes to cache' do
            expect(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
            stub = stub_request(:get, auth_server_url).
              to_return(body: response.to_json, status: 200)
            expect(Rails.cache).to receive(:write)

            expect(fetcher.fetch(request)).to be_accessible
            expect(stub).to have_been_requested
          end
        end

        context 'when cache does not hit and authz fails' do
          it 'does not write to cache and returns nil' do
            expect(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
            stub = stub_request(:get, auth_server_url).
              to_return(body: {}.to_json, status: 401)
            expect(Rails.cache).not_to receive(:write)

            expect(fetcher.fetch(request)).to be_nil
            expect(stub).to have_been_requested
          end
        end
      end

      context 'with access token on request parameter' do
        let(:request) { double(:request, authorization: nil, params: params, headers: {}) }
        let(:params) { { access_token: requested_token } }

        it 'does not read cache and requests access token' do
          expect(Rails.cache).not_to receive(:read)
          stub = stub_request(:get, auth_server_url + "?access_token=#{requested_token}").
            to_return(body: response.to_json, status: 200)

          expect(fetcher.fetch(request)).to be_accessible
          expect(stub).to have_been_requested
        end
      end

      context 'with basic authentication' do
        let(:secrets) { 'xxx:yyy' }
        let(:authorization) { "Basic #{Base64.strict_encode64(secrets)}" }
        let(:url) { auth_server_url.gsub(%r{\A(http://)(.*)\z}) { "#{$1}#{secrets}@#{$2}" } }

        it 'does not read cache and requests access token' do
          expect(Rails.cache).not_to receive(:read)
          stub = stub_request(:get, url).to_return(body: response.to_json, status: 200)

          expect(fetcher.fetch(request)).to be_accessible
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
