require 'epic/oauth/version'
require 'epic/oauth/client'
require 'epic/oauth/session'

module Epic
  module Oauth
    class Error < StandardError; end
    
    def self.configure(&block)
      block.call(configuration)
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.valid?
      return "'client_id' is missing from your configuration." if configuration.client_id.empty?
      return "'client_secret' is missing from your configuration." if configuration.client_secret.empty?
      return "'redirect_uri' is missing from your configuration." if configuration.redirect_uri.empty?

      true
    end

    class Configuration
      attr_writer :client_id, :client_secret, :redirect_uri, :debug

      def client_id
        @client_id
      end

      def client_secret
        @client_secret
      end

      def redirect_uri
        @redirect_uri
      end

      def debug
        @debug
      end
    end
  end
end
