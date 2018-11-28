require 'json'

module BotManager

  module Parsers

    class BotParser

      attr_reader :bot

      def initialize file_path
        @bot = JSON.parse(File.read(file_path), :symbolize_names => true)
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

    end

  end

end