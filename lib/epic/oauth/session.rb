module Epic
  module Oauth
    class Session

      def initialize(session = {}, access_token, refresh_token)

      end

      # @return [Boolean] true if session info will expire within 2 hours
      def expired?
      end

    end
  end
end