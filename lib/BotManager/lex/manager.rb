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

        put_response = @lex_client.put_slot_type definition

        @lex_client.create_slot_type_version slot_type.name, put_response["checksum"]

      end

      def register_intent intent

        puts "Registering intent: #{intent.name}"

        intent_checksum = @lex_client.get_intent_checksum intent.name, '$LATEST'

        definition = intent.to_h

        definition[:checksum] = intent_checksum

        put_response = @lex_client.put_intent definition

        @lex_client.create_intent_version intent.name, put_response["checksum"]

      end

      def register_bot bot

        puts "Registering bot: #{bot.name}"

        bot_checksum = @lex_client.get_bot_checksum bot.name, '$LATEST'

        definition = bot.to_h

        definition[:checksum] = bot_checksum

        put_response = @lex_client.put_bot definition

        version = @lex_client.create_bot_version bot.name, put_response["checksum"]

        bot_build_status = "NOT_BUILT"
        i = 0

        while ["BUILDING", "NOT_BUILT"].include?(bot_build_status)

          puts "Waiting for bot: #{bot.name} to be built"

          bot_build_status = @lex_client.get_bot_build_status bot.name, version

          sleep(2.pow(i))

          i += 1

          if i > 8
            puts "Exceeded max wait"
            return version
          end

        end

        puts "Finished building bot: #{bot.name}"

        version

      end

      end

    end

  end

end