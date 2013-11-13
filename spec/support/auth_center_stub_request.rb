require "securerandom"

helper = Module.new do
  def stub_access_token_response(attributes = {})
    stub_request(:get, Garage::AuthCenter::AccessTokenFetcher.url).to_return(
      body: {
        "token" => SecureRandom.hex(32),
        "expired_at" => 1.month.since,
        "scope" => "public",
        "token_type" => "bearer",
      }.merge(attributes.stringify_keys).to_json,
    )
  end
end
RSpec.configuration.include helper, type: :request
