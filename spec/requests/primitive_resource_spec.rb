require 'spec_helper'

describe 'Request to echo resource' do
  let(:application) { create(:application) }
  let(:user) { create(:user) }
  let(:token) { client_is_authorized(application, user).token }

  before do
    with_access_token_header token
  end

  it 'returns a hash' do
    get '/echo'
    body.should be_a Hash
    body.should == {"message" => "Hello World"}
  end
end
