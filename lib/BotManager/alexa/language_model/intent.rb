require 'set'

module BotManager

  module Alexa

    module LanguageModel

      class Intent

        attr_reader :samples, :name, :slots

        def initialize name
          @samples = Set.new
          @slots = Set.new
          @name = name
        end

        def add_sample sample
          @samples.add sample
        end

        def add_slot slot
          @slots.add slot.to_h
        end

        def to_h

          {
              name: @name,
              samples: @samples.to_a,
              slots: @slots.to_a
          }

        end

      end

    end

  end

end