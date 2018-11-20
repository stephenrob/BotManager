module BotManager

  module Alexa

    class Variation

      attr_reader :type, :value

      def initialize type, value

        @type = type
        @value = value

      end

      def to_h

        {
            type: @type,
            value: @value
        }

      end

    end

  end

end