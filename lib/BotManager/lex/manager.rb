require 'BotManager/lex/client'

module BotManager

  module Lex

    class Manager

      def initialize
        @lex_client = Client.new
      end

      def get_recent_slot_type_version slot_type_name

        versions = @lex_client.get_slot_type_versions slot_type_name

        versions = versions.keep_if {|v| v[:version] != '$LATEST'}

        if versions.length == 0
          return '$LATEST'
        end

        versions.sort! {|a, b| b[:version] <=> a[:version]}

        versions[0][:version]

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

        bot_build_status = {status: "NOT_BUILT"}
        i = 0

        while check_build_status_in ["BUILDING", "NOT_BUILT"], "#{bot_build_status[:status]}"

          puts "Waiting for bot: #{bot.name} to be built"

          bot_build_status = @lex_client.get_bot_build_status bot.name, version

          sleep(2.pow(i))

          i += 1

          if i > 8
            puts "Exceeded max wait"
            return version
          end

        end

        if bot_build_status[:status] == 'FAILED'
          puts "Failed to build bot: #{bot.name}"
          puts "Failure Caused by: #{bot_build_status[:failure_reason]}"
          raise "FailedToBuildBot"
        end

        puts "Finished building bot: #{bot.name}"

        version

      end

      def update_bot_alias bot_name, version, bot_alias

        puts "Updating bot alias #{bot_alias} for bot: #{bot_name}"

        alias_checksum = @lex_client.get_bot_alias_checksum bot_name, bot_alias

        @lex_client.put_bot_alias bot_name, version, bot_alias, alias_checksum

      end

      def cleanup_slot_type_versions slot_type_name, max_to_keep, versions_to_ignore

        versions = @lex_client.get_slot_type_versions slot_type_name

        versions = versions.keep_if { |v| !versions_to_ignore.include? v[:version] }

        if versions.length > max_to_keep

          versions.sort! {|a,b| a[:last_updated_date] <=> b[:last_updated_date]}

          versions_to_delete = versions[0...-max_to_keep]

          versions_to_delete.each do |version|

            version_id = version[:version]

            puts "Removing version #{version_id} from slot type #{slot_type_name}"

            @lex_client.delete_slot_type_version slot_type_name, version_id

            sleep(5)

          end

        end

      end

      def cleanup_intent_versions intent_name, max_to_keep, versions_to_ignore

        versions = @lex_client.get_intent_versions intent_name

        versions = versions.keep_if { |v| !versions_to_ignore.include? v[:version] }

        if versions.length > max_to_keep

          versions.sort! {|a,b| a[:last_updated_date] <=> b[:last_updated_date]}

          versions_to_delete = versions[0...-max_to_keep]

          versions_to_delete.each do |version|

            version_id = version[:version]

            puts "Removing version #{version_id} from intent #{intent_name}"

            @lex_client.delete_intent_version intent_name, version_id

            sleep(5)

          end

        end

      end

      def cleanup_bot_versions bot_name, max_to_keep, versions_to_ignore

        versions = @lex_client.get_bot_versions bot_name

        versions = versions.keep_if { |v| !versions_to_ignore.include? v[:version] }

        if versions.length > max_to_keep

          versions.sort! {|a,b| a[:last_updated_date] <=> b[:last_updated_date]}

          versions_to_delete = versions[0...-max_to_keep]

          versions_to_delete.each do |version|

            version_id = version[:version]

            puts "Removing version #{version_id} from bot #{bot_name}"

            @lex_client.delete_bot_version bot_name, version_id

            sleep(5)

          end

        end

      end

      def check_build_status_in array, build_status

        array.include?(build_status)

      end

    end

  end

end