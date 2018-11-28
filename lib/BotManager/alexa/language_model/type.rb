require 'set'

module BotManager

  module Alexa

    module LanguageModel

      class Type

        attr_reader :name, :values

        def initialize name
          @values = []
          @name = name
        end

        def add_value value
          formatted_value = {
              name: {
                  value: value
              }
          }
          @values.append formatted_value
        end

        def to_h

          {
              name: @name,
              values: @values
          }

        end

      end

    end

  end

end