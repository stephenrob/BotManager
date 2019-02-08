require 'set'

module BotManager

  module Lex

    class Intent

      attr_reader :name, :description, :sample_utterances, :fulfillment_activity, :slots, :conclusion_statement

      def initialize name, description
        @name = name
        @description = description
        @sample_utterances = Set.new
        @slots = []
      end

      def add_sample_utterance utterance
        @sample_utterances.add utterance
      end

      def set_fulfillment_activity fulfillment_activity
        @fulfillment_activity = fulfillment_activity.to_h
      end

      def set_conclusion_statement conclusion_statement
        @conclusion_statement = conclusion_statement.to_h
      end

      def register_slot slot
        @slots.push slot.to_h
      end

      def to_h
        {
            name: @name,
            description: @description,
            slots: @slots,
            sample_utterances: @sample_utterances,
            fulfillment_activity: @fulfillment_activity,
            conclusion_statement: @conclusion_statement
        }
      end

    end

  end

end