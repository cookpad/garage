require 'spec_helper'

describe 'Cache-Control headers' do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user, :scopes => "public").token }
  let(:path) { "/users/#{user.id}/posts" }

  before do
    with_access_token_header token
  end

  it 'gets first reponse without cached' do
    get path
    last_response.headers.should_not have_key 'X-Garage-Cache'
  end

  it 'gets second response with cache' do
    get path
    get path
    last_response.headers.should have_key 'X-Garage-Cache'
  end

  it 'gets second response with Cache-Control no-cache' do
    get path
    header 'Cache-Control', 'no-cache'
    get path
    last_response.headers.should_not have_key 'X-Garage-Cache'
  end
end
