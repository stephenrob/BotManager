module BotManager

  module Lex

    class CodeHookFulfillmentActivity

      TYPE = "CodeHook"
      MESSAGE_VERSION = "1.0"

      attr_reader :uri

      def initialize uri
        @uri = uri
      end

      def to_h

        {
            type: TYPE,
            code_hook: {
                uri: @uri,
                message_version: MESSAGE_VERSION
            }
        }

      end

    end

  end

end