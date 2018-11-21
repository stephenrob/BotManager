require 'BotManager/lex/client'

module BotManager

  module Lex

    class Manager

      def initialize
        @lex_client = Client.new
      end

      def register_slot_type slot_type

        puts "Registering slot type: #{slot_type.name}"

        slot_type_checksum = @lex_client.get_slot_type_checksum slot_type.name, '$LATEST'

        definition = slot_type.to_h

        definition[:checksum] = slot_type_checksum

        @lex_client.put_slot_type definition

      end

      def register_intent intent

        puts "Registering intent: #{intent.name}"

        intent_checksum = @lex_client.get_intent_checksum intent.name, '$LATEST'

        definition = intent.to_h

        definition[:checksum] = intent_checksum

        @lex_client.put_intent definition

      end

      def register_bot bot

        puts "Registering bot: #{bot.name}"

        bot_checksum = @lex_client.get_bot_checksum bot.name, '$LATEST'

        definition = bot.to_h

        definition[:checksum] = bot_checksum

        @lex_client.put_bot definition

      end

    end

  end

end