require 'set'

module BotManager

  module Lex

    class ValueElicitationPrompt

      attr_reader :max_attempts, :messages

      def initialize max_attempts
        @max_attempts = max_attempts
        @messages = Set.new
      end

      def add_message type, content
        message = {
            content_type: type,
            content: content
        }
        @messages.add message
      end

      def to_h

        {
            messages: @messages.to_a,
            max_attempts: @max_attempts
        }

      end

    end

  end

end