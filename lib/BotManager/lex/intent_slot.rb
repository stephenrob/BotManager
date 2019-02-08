require 'set'

module BotManager

  module Lex

    class IntentSlot

      attr_reader :name, :description, :value_elicitation_prompt, :sample_utterances
      attr_accessor :slot_constraint, :slot_type, :slot_type_version

      def initialize name, description
        @name = name
        @description = description
        @sample_utterances = Set.new
      end

      def set_value_elicitation_prompt value_elicitation_prompt
        @value_elicitation_prompt = value_elicitation_prompt
      end

      def add_utterance uttterance
        @sample_utterances.add uttterance
      end

      def to_h

        hash = {
            name: @name,
            description: @description,
            slot_constraint: @slot_constraint,
            slot_type: @slot_type,
            value_elicitation_prompt: @value_elicitation_prompt.to_h,
            sample_utterances: @sample_utterances.to_a
        }

        if !@slot_type.start_with?('AMAZON')
          hash.merge!({slot_type_version: @slot_type_version})
        end

        hash

      end

    end

  end

end