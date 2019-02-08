require 'set'

module BotManager

  module Lex

    class SlotType

      attr_reader :name, :description, :enumeration_values

      def initialize name, description
        @name = name
        @description = description
        @enumeration_values = Set.new
      end

      def add_enumeration_value enumeration_value
        @enumeration_values.add enumeration_value.to_h
      end

      def to_h
        {
            name: @name,
            description: @description,
            enumeration_values: @enumeration_values.to_a
        }
      end

    end

  end

end