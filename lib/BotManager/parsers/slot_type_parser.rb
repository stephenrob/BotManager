require 'json'
require 'BotManager/parsers/template_file_parser'

module BotManager

  module Parsers

    class SlotTypeParser

      attr_reader :slot_type

      def initialize file_path
        file = TemplateFileParser.parse(file_path)
        @slot_type = JSON.parse(file, :symbolize_names => true)
      end

      def name
        @slot_type[:name]
      end

      def description
        @slot_type[:description]
      end

      def enumeration_values
        @slot_type[:enumeration_values]
      end

    end

  end

end