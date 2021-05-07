module Epic
  module Oauth
    class Session
      attr_accessor :token, :identity

      def initialize(token, identity)
        @token = token
        @identity = identity
      end

      def expired?
        (DateTime.now + (1 / 24.0)) > DateTime.parse(token['expires_at'])
      end

      def access_token_expired?
        (DateTime.now + (1 / 24.0)) > DateTime.parse(token['expires_at'])
      end

      def refresh_token_expired?
        (DateTime.now + (1 / 24.0)) > DateTime.parse(token['expires_at']) if token['refresh_expires_at']
      end

      def active?
        Epic::Oauth::Client.new(token, identity).verify['active']
      end
    end
  end
end