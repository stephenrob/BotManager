require 'json'

module BotManager

  module Parsers

    class SlotTypeParser

      attr_reader :slot_type

      def initialize file_path
        @slot_type = JSON.parse(File.read(file_path), :symbolize_names => true)
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