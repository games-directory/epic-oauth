require 'httparty'

module Epic
  module Oauth
    class Client
      DEFAULT_SCOPES ||= ['basic_profile', 'friends_list', 'presence'].join(' ').freeze
      
      include HTTParty

      base_uri 'https://api.epicgames.dev/epic'

      attr_reader :token, :identity

      def self.authorization_url
        params = {
          client_id: Epic::Oauth.configuration.client_id,
          response_type: 'code',
          scope: DEFAULT_SCOPES,
          redirect_uri: Epic::Oauth.configuration.redirect_uri
        }

        "https://www.epicgames.com/id/authorize?#{ URI.encode_www_form(params) }"
      end

      def initialize(token = nil, identity = nil)
        @token = token if token
        @identity = identity if token
      end

      def authenticate(code, refresh: false)
        @token = request_oauth_token(code, refresh: refresh)
        @identity = account_info

        Epic::Oauth::Session.new(token, identity)
      end

      def refresh(refresh_token)
        authenticate(refresh_token, refresh: true)
      end

      def request_oauth_token(code, refresh: false)
        raise '"code" is empty; you need it silly! Did you forget to launch @authorization_url?' unless code

        body = {
          grant_type: (refresh ? 'refresh_token' : 'authorization_code'),
          client_id: Epic::Oauth.configuration.client_id,
          scope: DEFAULT_SCOPES,
          token_type: 'eg1',
          redirect_uri: Epic::Oauth.configuration.redirect_uri
        }

        body[refresh ? 'refresh_token' : 'code'] = code

        request = self.class.post('/oauth/v1/token',
          headers: {
            Authorization: "Basic #{ client_token }"
          },
          body: body
        ).parsed_response

        return request
      end

      def account_info
        raise '"account_id" is missing; you need it silly!' unless token['account_id']

        request = self.class.get('/id/v1/accounts',
          headers: {
            Authorization: "Bearer #{ token['access_token'] }"
          },
          query: {
            accountId: token['account_id']
          }
        )
        
        request.parsed_response
      end

      def verify_token
        raise '"access_token" is missing; you need it silly!' unless token['access_token']

        request = self.class.post('/oauth/v1/tokenInfo',
          body: {
            token: token['access_token']
          }
        )
        
        request.parsed_response
      end

    private

      def client_token
        Base64.urlsafe_encode64([Epic::Oauth.configuration.client_id, Epic::Oauth.configuration.client_secret].join(':'))
      end
    end
  end
end