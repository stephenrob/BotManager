require 'set'

module BotManager

  module Alexa

    module Dialog

      class Slot

        attr_reader :name, :type, :confirmation_required, :elicitation_required, :prompts, :validations

        def initialize name, type, confirmation_required, elicitation_required
          @prompts = {}
          @validations = Set.new
          @name = name
          @type = type
          @confirmation_required = confirmation_required
          @elicitation_required = elicitation_required
        end

        def set_elicitation elicitation
          @prompts[:elicitation] = elicitation.id
        end

        def add_validation validation
          @validations.add validation.to_h
        end

        def to_h

          {
              name: @name,
              type: @type,
              confirmationRequired: @confirmation_required,
              elicitationRequired: @elicitation_required,
              prompts: @prompts,
              validations: @validations.to_a
          }

        end

      end

    end

  end

end