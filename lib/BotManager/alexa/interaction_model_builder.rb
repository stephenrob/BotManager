require 'set'

module BotManager

  module Alexa

    class InteractionModelBuilder

      attr_reader :prompts

      def initialize
        @prompts = Set.new
        @language_model = nil
        @dialog = nil
      end

      def register_prompt prompt
        @prompts.add prompt.to_h
      end

      def add_dialog dialog
        @dialog = dialog
      end

      def add_language_model language_model
        @language_model = language_model
      end

      def to_h

        {
            interactionModel: {
                languageModel: @language_model,
                dialog: @dialog,
                prompts: @prompts.to_a
            }
        }

      end

    end

  end

end