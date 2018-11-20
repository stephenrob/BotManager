module BotManager

  module Alexa

    class SkillManifestBuilder

      attr_reader :privacy_and_compliance, :endpoint, :publishing_options

      MANIFEST_VERSION = "1.0"

      def initialize
        @locales = {}
      end

      def register_locale locale
        @locales[locale.slug] = locale.to_h.dup.keep_if { |k, _v| ![:privacyPolicyUrl, :termsOfUseUrl].include? k }
      end

      def register_endpoint endpoint
        @endpoint = endpoint
      end

      def add_privacy_and_compliance privacy
        @privacy_and_compliance = privacy
      end

      def register_publishing_options publishing_options
        @publishing_options = publishing_options
      end

      def to_h

        {
            manifest: {
                publishingInformation: {
                    locales: @locales,
                    isAvailableWorldwide: @publishing_options.is_available_worldwide,
                    testingInstructions: @publishing_options.testing_instructions,
                    category: @publishing_options.category,
                    distributionCountries: @publishing_options.distribution_countries.to_a
                },
                apis: {
                    custom: {
                        endpoint: {
                            uri: @endpoint
                        },
                        interfaces: []
                    }
                },
                manifestVersion: MANIFEST_VERSION,
                privacyAndCompliance: @privacy_and_compliance.to_h
            }
        }

      end

    end

  end

end