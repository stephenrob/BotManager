require 'set'

module BotManager

  module Alexa

    module Manifest

      class PublishingOptions

        attr_reader :distribution_countries
        attr_accessor :is_available_worldwide, :testing_instructions, :category

        def initialize
          @distribution_countries = Set.new
        end

        def add_distribution_country country
          @distribution_countries.add country
        end

      end

    end

  end

end