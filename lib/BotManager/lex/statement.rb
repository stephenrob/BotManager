require 'set'

module BotManager

  module Lex

    class Statement

      attr_reader :messages

      def initialize
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
            messages: @messages.to_a
        }

      end

    end

  end

end