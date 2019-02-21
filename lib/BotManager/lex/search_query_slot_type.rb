require 'set'
require 'json'
require_relative 'enumeration_value'
require_relative 'slot_type'

module BotManager

  module Lex

    class SearchQuerySlotType < SlotType

      def initialize name, description
        super name, description
        load_default_enumerations
      end

      private

      def load_default_enumerations
        default_enumerations = JSON.parse("#{__dir__}/assets/default_search_enumerations.json")

        default_enumerations.each do |value|
          enumeration = EnumerationValue.new value
          add_enumeration_value enumeration
        end

      end

    end

  end

end
