require 'set'

module BotManager

  module Alexa

    module Dialog

      class Builder

        attr_reader :intents

        def initialize
          @intents = Set.new
        end

        def register_intent intent
          @intents.add intent.to_h
        end

        def to_h

          {
              intents: @intents.to_a
          }

        end

      end

    end

  end

end