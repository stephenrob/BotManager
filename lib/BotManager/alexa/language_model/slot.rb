require 'set'

module BotManager

  module Alexa

    module LanguageModel

      class Slot

        attr_reader :samples, :name, :type

        def initialize name, type
          @samples = Set.new
          @name = name
          @type = type
        end

        def add_sample sample
          @samples.add sample
        end

        def to_h

          {
              name: @name,
              type: @type,
              samples: @samples.to_a
          }

        end

      end

    end

  end

end