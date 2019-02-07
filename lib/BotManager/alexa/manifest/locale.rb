require 'set'

module BotManager

  module Alexa

    module Manifest

      class Locale

        attr_reader :slug, :phrases, :keywords, :name, :description
        attr_accessor :small_icon_uri, :large_icon_uri, :summary, :terms_of_use_url, :privacy_policy_url

        def initialize slug, name, description
          @slug = slug
          @name = name
          @description = description
          @phrases = Set.new
          @keywords = Set.new
        end

        def add_example_phrase phrase
          @phrases.add phrase
        end

        def add_keyword keyword
          @keywords.add keyword
        end

        def to_h

          {
              summary: @summary,
              examplePhrases: @phrases.to_a,
              keywords: @keywords.to_a,
              smallIconUri: @small_icon_uri,
              largeIconUri: @large_icon_uri,
              name: @name,
              description: @description,
              privacyPolicyUrl: @privacy_policy_url,
              termsOfUseUrl: @terms_of_use_url
          }

        end

      end

    end

  end

end