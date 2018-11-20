require 'set'

module BotManager

  module Lex

    class Slot

      attr_reader :name, :description, :enumeration_values

      def initialize name, description
        @name = name,
        @description = description
        @enumeration_values = Set.new
      end

      def add_enumeration_value enumeration_value
        @enumeration_values.add enumeration_value.to_h
      end

    end

  end

end