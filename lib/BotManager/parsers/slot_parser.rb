require 'json'

module BotManager

  module Parsers

    class SlotParser

      attr_reader :slot

      def initialize file_path
        @slot = JSON.parse(File.read(file_path), :symbolize_names => true)
      end

      def name
        @slot[:name]
      end

      def description
        @slot[:description]
      end

      def type
        @slot[:type]
      end

      def constraint
        @slot[:constraint]
      end

      def elicitation_prompt
        @slot[:elicitation_prompt]
      end

      def sample_utterances
        @slot[:sample_utterances]
      end

      def lex
        @slot[:lex]
      end

      def alexa
        @slot[:alexa]
      end

    end

  end

end