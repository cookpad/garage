require "securerandom"

module Garage
  module Test
    module AuthenticationHelper
      def stub_access_token_request(attributes = {})
        stub_request(:get, Garage.configuration.auth_center_url).to_return(
          body: HashWithIndifferentAccess.new(
            application_id: SecureRandom.hex(32),
            expired_at: 1.month.since,
            scope: "",
            token: SecureRandom.hex(32),
            token_scope: "bearer",
          ).merge(attributes).to_json,
        )
      end
    end
  end
end
