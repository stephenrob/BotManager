require 'BotManager/alexa/api/client'

module BotManager

  module Alexa

    class Manager

      def initialize client_id, client_secret, refresh_token
        @client = Api::Client.new client_id, client_secret, refresh_token
      end

    end

  end

end