module BotManager

  module Lex

    class BuiltInIntent

      attr_reader :name, :builtin_intent_name, :fulfillment_activity

      def initialize builtin_intent_name, name
        @builtin_intent_name = builtin_intent_name
        @name = name
      end

      def set_fulfillment_activity fulfillment_activity
        @fulfillment_activity = fulfillment_activity.to_h
      end

      def to_h
        {
            name: @name,
            parent_intent_signature: @builtin_intent_name,
            fulfillment_activity: @fulfillment_activity
        }
      end

    end

  end

end