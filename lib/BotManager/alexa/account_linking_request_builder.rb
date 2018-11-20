require 'json'
require 'set'

module BotManager

  module Alexa

    class AccountLinkingRequestBuilder

      attr_accessor :skip_on_enablement, :type, :authorization_url, :client_id, :client_secret, :access_token_url, :access_token_scheme, :default_token_expiration_in_seconds

      attr_reader :domains, :scopes

      def initialize
        self.default_token_expiration_in_seconds = 3600
        self.skip_on_enablement = false
        self.type = "AUTH_CODE"
        self.access_token_scheme = "HTTP_BASIC"
        @domains = Set.new
        @scopes = Set.new
      end

      def add_domain domain
        self.domains.add domain
      end

      def add_scope scope
        self.scopes.add scope
      end

      def to_h

        {
            accountLinkingRequest: {
                skipOnEnablement: self.skip_on_enablement,
                type: self.type,
                authorizationUrl: self.authorization_url,
                domains: self.domains.to_a,
                clientId: self.client_id,
                clientSecret: self.client_secret,
                scopes: self.scopes.to_a,
                accessTokenUrl: self.access_token_scheme,
                accessTokenScheme: self.access_token_scheme,
                defaultTokenExpirationInSeconds: self.default_token_expiration_in_seconds
            }
        }

      end

      def to_json
        to_h.to_json
      end

    end

  end

end