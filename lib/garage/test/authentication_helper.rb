require "securerandom"
require "hashie/mash"

module Garage
  module Test
    module AuthenticationHelper
      def stub_access_token_request(attributes = {})
        Hashie::Mash.new(
          application_id: SecureRandom.hex(32),
          expired_at: 1.month.since,
          scope: "",
          token: SecureRandom.hex(32),
          token_scope: "bearer",
        ).merge(attributes).tap do |access_token|
          stub_request(:get, Garage.configuration.auth_center_url).to_return(body: access_token.to_json)
        end
      end
    end
  end
end
