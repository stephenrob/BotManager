require 'set'

module BotManager

  module Alexa

    module Dialog

      class SlotValidation

        attr_reader :prompt_id, :values, :type

        def initialize type
          @values = Set.new
          @type = type
        end

        def set_validation_prompt prompt
          @prompt_id = prompt.id
        end

        def add_value value
          @values.add value
        end

        def to_h

          hash = {
              type: @type,
              prompt: @prompt_id
          }

          if !@values.empty?
            hash.merge!({values: @values.to_a})
          end

          hash

        end

      end

    end

  end

end