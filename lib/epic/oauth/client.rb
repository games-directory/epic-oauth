require 'httparty'

module Epic
  module Oauth
    class Client
      include HTTParty

      DEFAULT_SCOPES ||= ['basic_profile', 'friends_list', 'presence'].join(' ').freeze

      def self.authorization_url
        params = {
          client_id: Epic::Oauth.configuration.client_id,
          response_type: 'code',
          scope: DEFAULT_SCOPES,
          redirect_uri: Epic::Oauth.configuration.redirect_uri
        }

        "https://www.epicgames.com/id/authorize?#{ URI.encode_www_form(params) }"
      end

      def initialize
        # raise 'Please read the README.md on how to configure the XBOX::Oauth module.' unless XBOX::Oauth.valid?
      end

      def authenticate(code, refresh: false)

        # Start the Authentication flow
        #
        access_token, refresh_token = request_oauth_token(code, refresh: refresh)
        user_token = get_user_token(access_token)
        session = get_xsts_token(user_token)

        # Return a new Session containing all the required information to start communicating with XBOX Live API
        #
        XBOX::Oauth::Session.new(session, access_token, refresh_token)
      end

      def refresh(refresh_token)
        authenticate(refresh_token, refresh: true)
      end

      # TODO: Add a way for the User to request the app be removed from their allowed oauth services
      #
      def delete(refresh_token)
        # self.class.delete()
      end

      ## Authenticate the account via the authorization code returned by @oauth_authorize_url and receive an access and
      # refresh token
      #
      # @return [Hash] containing the access_token, refresh_token, expiration_date, etc..
      # @example
      #
      def request_oauth_token(code, refresh: false)
        raise '"code" is empty; you need it silly! Did you forget to launch @authorization_url?' unless code

        body = {
          grant_type: (refresh ? 'refresh_token' : 'authorization_code'),
          client_id: XBOX::Oauth.configuration.client_id,
          scope: DEFAULT_SCOPES,
          redirect_uri: XBOX::Oauth.configuration.redirect_uri
        }

        body[refresh ? 'refresh_token' : 'code'] = code
        body[:client_secret] = client_secret unless (client_secret = XBOX::Oauth.configuration.client_secret)

        request = self.class.post('https://login.live.com/oauth20_token.srf',
          body: body
        ).parsed_response

        raise request['error_description'] if request.has_key?('error')

        return request['access_token'], request['refresh_token']
      end

      # Authenticate with XBOX Live using the user's access_token returned by @request_oauth_token and receive a
      # user_token and uhs id which are to be used with @get_xsts_token
      #
      # @return
      # @example
      #
      def get_user_token(access_token)
        raise '"access_token" is empty; you need it silly!' unless access_token

        request = self.class.post('https://user.auth.xboxlive.com/user/authenticate',
          body: {
            'RelyingParty' => 'http://auth.xboxlive.com',
            'TokenType' => 'JWT',
            'Properties' => {
              'AuthMethod' => 'RPS',
              'SiteName' => 'user.auth.xboxlive.com',
              'RpsTicket' => "d=#{ access_token }"
            }
          }.to_json,

          headers: {
            'Content-Type' => 'application/json',
            'x-xbl-contract-version' => '1'
          }
        )

        request.parsed_response['Token']
      end

      # Authorize via user token and receive final X token
      #
      # @return [Hash]
      #
      def get_xsts_token(user_tokens = [])
        raise '"user_tokens" is empty; you need it silly!' if user_tokens.empty?

        request = self.class.post('https://xsts.auth.xboxlive.com/xsts/authorize',
          body: {
            'RelyingParty' => 'http://xboxlive.com',
            'TokenType' => 'JWT',
            'Properties' => {
              'UserTokens' => [user_tokens],
              # 'DeviceToken' => '',
              # 'TitleToken' => '',
              # 'OptionalDisplayClaims' => [''],
              'SandboxId' => 'RETAIL'
            }
          }.to_json,

          headers: {
            'Content-Type' => 'application/json',
            'x-xbl-contract-version' => '1'
          }
        )

        raise 'An error occured in get_xsts_token' if request.code != 200

        request.parsed_response
      end
    end
  end
end