require 'set'

module BotManager

  module Lex

    class EnumerationValue

      attr_reader :name, :synonyms

      def initialize name
        @name = name
        @synonyms = Set.new
      end

      def add_synonym synonym
        @synonyms.add synonym
      end

      def to_h

        {
            value: name,
            synonyms: synonyms.to_a
        }

      end

    end

  end

end