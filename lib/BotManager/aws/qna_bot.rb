require 'BotManager/lex'

module BotManager

  module Aws

    class QnaBot

      attr_reader :name, :version

      def initialize name, version
        @name = name
        @version = version
        @lex_client = Lex::Client.new
        @bot = retrieve_bot
        @intent = retrieve_intent
        @slot_type = retrieve_slot_type
      end

      def get_slot_enumerations
        @slot_type[:enumeration_values]
      end

      def get_fulfillment_activity

        @intent[:fulfillment_activity]

      end

      private

      def retrieve_bot
        @lex_client.get_bot @name, @version
      end

      def retrieve_slot_type

        slot_type = @intent[:slots][0][:slot_type]
        slot_type_version = @intent[:slots][0][:slot_type_version]

        @lex_client.get_slot_type slot_type, slot_type_version

      end

      def retrieve_intent

        intent_name = @bot[:intents][0][:intent_name]
        intent_version = @bot[:intents][0][:intent_version]

        @lex_client.get_intent intent_name, intent_version
      end

    end

  end

end