module Garage
  module Strategy
    class AccessToken
      attr_reader :scope, :token, :token_type

      def initialize(attrs)
        @scope, @token, @token_type = attrs[:scope], attrs[:token], attrs[:token_type]
        @application_id, @resource_owner_id = attrs[:application_id], attrs[:resource_owner_id]
        @expired_at, @revoked_at = attrs[:expired_at], attrs[:revoked_at]
      end

      def application_id
        @application_id.try(:to_i)
      end

      def resource_owner_id
        @resource_owner_id.try(:to_i)
      end

      def expired_at
        @expired_at.present? ? Time.zone.parse(@expired_at) : nil
      rescue ArgumentError, TypeError
        nil
      end

      def revoked_at
        @revoked_at.present? ? Time.zone.parse(@revoked_at) : nil
      rescue ArgumentError, TypeError
        nil
      end

      def scopes
        scope.try(:split, ' ')
      end

      def acceptable?(required_scopes)
        accessible? && includes_scope?(required_scopes)
      end

      def accessible?
        valid? && !revoked? && !expired?
      end

      def valid?
        token.present? && token_type.present?
      end

      def revoked?
        !!revoked_at.try(:past?)
      end

      def expired?
        !!expired_at.try(:past?)
      end

      def includes_scope?(required_scopes)
        required_scopes.blank? || required_scopes.any? { |s| scopes.exists?(s) }
      end
    end
  end
end
