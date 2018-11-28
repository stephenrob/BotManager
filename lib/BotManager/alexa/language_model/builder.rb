require 'set'

module BotManager

  module Alexa

    module LanguageModel

      class Builder

        attr_reader :invocation_name, :intents, :types

        def initialize invocation_name
          @invocation_name = invocation_name
          @intents = Set.new
          @types = Set.new
        end

        def register_intent intent
          @intents.add intent.to_h
        end

        def register_type type
          @types.add type.to_h
        end

        def to_h

          {
              invocationName: @invocation_name,
              intents: @intents.to_a,
              types: @types.to_a
          }

        end

      end

    end

  end

end