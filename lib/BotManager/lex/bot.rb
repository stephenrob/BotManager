require 'set'

module BotManager

  module Lex

    class Bot

      attr_reader :name, :description, :intents, :clarification_prompt, :abort_statement
      attr_accessor :idle_session_ttl_in_seconds, :voice_id, :locale, :child_directed

      def initialize name, description
        @name = name
        @description = description
        @intents = Set.new
        @child_directed = false
        @idle_session_ttl_in_seconds = 300
      end

      def register_intent name, version
        intent = {
            intent_name: name,
            intent_version: version
        }
        @intents.add intent
      end

      def set_clarification_prompt clarification_prompt
        @clarification_prompt = clarification_prompt.to_h
      end

      def set_about_statement abort_statement
        @abort_statement = abort_statement.to_h
      end

      def to_h

        {
            name: @name,
            description: @description,
            intents: @intents.to_a,
            clarification_prompt: @clarification_prompt,
            abort_statement: @abort_statement,
            idle_session_ttl_in_seconds: @idle_session_ttl_in_seconds,
            voice_id: @voice_id,
            locale: @locale,
            child_directed: @child_directed
        }

      end

    end

  end

end