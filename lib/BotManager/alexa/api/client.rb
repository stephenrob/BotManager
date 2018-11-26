require 'oauth2'

module BotManager

  module Alexa

    module Api

      class Client < ::OAuth2::AccessToken

        def initialize client_id, client_secret, refresh_token

          oauth2 = OAuth2::Client.new client_id,
                             client_secret,
                             :site => "https://api.amazonalexa.com/",
                             :authorize_url => "https://www.amazon.com/ap/oa",
                             :token_url => "https://api.amazon.com/auth/o2/token",
                             :header_format => "%s"

          params = {
              refresh_token: refresh_token,
              header_format: "%s"
          }

          super(oauth2, '', params)

          new_token = self.refresh!

          @token = new_token.token
          @expires_in = new_token.expires_in.to_i
          @expires_at = new_token.expires_at.to_i

        end

        def refresh_token!
          new_token = self.refresh!

          @token = new_token.token
          @expires_in = new_token.expires_in.to_i
          @expires_at = new_token.expires_at.to_i
          @token
        end

      end

    end

  end

end