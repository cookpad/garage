module Garage
  module Strategy
    module Test
      extend ActiveSupport::Concern

      included do
        before_action :verify_auth, if: -> (_) { verify_permission? }
      end

      def access_token
        if defined? @access_token
          @access_token
        else
          token = AccessToken.new(attributes.merge(token: requested_token, token_type: 'bearer'))
          @access_token = token.token.present? && token.accessible? ? token : nil
        end
      end

      def verify_permission?
        true
      end

      private

      def attribute_names
        %i(application_id expired_at resource_owner_id scope)
      end

      def attributes
        Hash[attribute_names.map {|name| [name, from_header(name)] }]
      end

      def from_header(name)
        canonical = name.to_s.dasherize.split('-').map(&:capitalize).join('-')
        request.headers[canonical]
      end

      def requested_token
        value = request.authorization
        value.present? ? value.gsub(/^Bearer\s(.*)/) { $1 } : nil
      end
    end
  end
end
