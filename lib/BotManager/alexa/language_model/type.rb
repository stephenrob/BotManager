require 'set'

module BotManager

  module Alexa

    module LanguageModel

      class Type

        attr_reader :name, :values

        def initialize name, type
          @values = Set.new
          @name = name
        end

        def add_value value
          formatted_value = {
              name: {
                  value: value
              }
          }
          @values.add formatted_value
        end

        def to_h

          {
              name: @name,
              values: @values.to_a
          }

        end

      end

    end

  end

end