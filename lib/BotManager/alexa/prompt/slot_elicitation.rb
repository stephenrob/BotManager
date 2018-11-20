require 'set'
require 'BotManager/alexa/prompt/variation'

module BotManager

  module Alexa

    module Prompt

      class SlotElicitation

        attr_reader :variations, :intent, :slot

        def initialize intent, slot
          @variations = Set.new
          @intent = intent
          @slot = slot
        end

        def add_variation type, value
          variation = Variation.new type, value
          @variations.add variation.to_h
        end

        def id
          "Elicit.Intent-#{@intent}.IntentSlot-#{@slot}"
        end

        def to_h

          {
              id: id,
              variations: variations
          }

        end

      end

    end

  end

end