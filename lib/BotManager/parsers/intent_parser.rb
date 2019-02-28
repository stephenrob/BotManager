require 'json'
require 'BotManager/parsers/template_file_parser'

module BotManager

  module Parsers

    class IntentParser

      attr_reader :intent

      def initialize file_path
        file = TemplateFileParser.parse(file_path)
        @intent = JSON.parse(file, :symbolize_names => true)
      end

      def name
        @intent[:name]
      end

      def description
        @intent[:description]
      end

      def type
        @intent[:type]
      end

      def sample_utterances
        @intent[:sample_utterances]
      end

      def lex
        @intent[:lex]
      end

      def slots
        @intent[:slots]
      end

    end

  end

end