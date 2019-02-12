require 'json'
require 'BotManager/parsers/template_file_parser'

module BotManager

  module Parsers

    class BotParser

      attr_reader :bot

      def initialize file_path
        file = TemplateFileParser.parse(file_path)
        @bot = JSON.parse(file, :symbolize_names => true)
      end

      def name
        @bot[:name]
      end

      def description
        @bot[:description]
      end

      def alexa
        @bot[:alexa]
      end

      def lex
        @bot[:lex]
      end

      def privacy_and_compliance
        @bot[:privacy_and_compliance]
      end

      def intents
        @bot[:intents]
      end

      def aws_qna_intents
        @bot[:aws_qna_intents]
      end

    end

  end

end