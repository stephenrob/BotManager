require 'aws-sdk-lexmodelbuildingservice'

module BotManager

  module Lex

    class Client

      def initialize
        @lex = Aws::LexModelBuildingService::Client.new
      end

      def get_slot_type_checksum name, version
        params = {name: name, version: version}
        begin
          slot_type = @lex.get_slot_type params
          slot_type["checksum"]
        rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
          nil
        end
      end

      def get_intent_checksum name, version
        params = {name: name, version: version}
        begin
          intent = @lex.get_intent params
          intent["checksum"]
        rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
          nil
        end
      end

      def get_bot_checksum name, version
        params = {name: name, version_or_alias: version}
        begin
          bot = @lex.get_bot params
          bot["checksum"]
        rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
          nil
        end
      end

      def get_bot_alias_checksum bot_name, alias_name
        params = {bot_name: bot_name, name: alias_name}
        begin
          bot_alias = @lex.get_bot_alias params
          bot_alias["checksum"]
        rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
          nil
        end
      end

      def create_slot_type_version name, checksum
        params = {name: name, checksum: checksum}
        begin
          slot_type = @lex.create_slot_type_version params
          slot_type["version"]
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          nil
        end
      end

      def create_intent_version name, checksum
        params = {name: name, checksum: checksum}
        begin
          intent = @lex.create_intent_version params
          intent["version"]
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          nil
        end
      end

      def create_bot_version name, checksum
        params = {name: name, checksum: checksum}
        begin
          bot = @lex.create_bot_version params
          bot["version"]
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          nil
        end
      end
      def put_slot_type slot_type_definition
        begin
          @lex.put_slot_type slot_type_definition
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          puts e
        end
      end

      def put_intent intent_definition
        begin
          @lex.put_intent intent_definition
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          puts e
        end
      end

      def put_bot bot_definition
        begin
          @lex.put_bot bot_definition
        rescue Aws::LexModelBuildingService::Errors::ServiceError => e
          puts e
        end
      end

      def get_bot_build_status bot_name, version_or_alias
        params = {name: bot_name, version_or_alias: version_or_alias}
        begin
          bot = @lex.get_bot params
          bot["status"]
        rescue Aws::LexModelBuildingService::Errors::NotFoundException => e
          puts e
          nil
        end
      end

    end

  end

end