require 'set'

module BotManager

  module Alexa

    module Dialog

      class Intent

        attr_reader :name, :slots, :confirmation_required

        def initialize name, confirmation_required
          @slots = Set.new
          @name = name
          @confirmation_required = confirmation_required
        end

        def add_slot slot
          @slots.add slot.to_h
        end

        def to_h

          {
              name: @name,
              confirmationRequired: @confirmation_required,
              prompts: {},
              slots: @slots.to_a
          }

        end

      end

    end

  end

end