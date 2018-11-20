require 'BotManager/alexa/builders/skill_manifest_builder'

module BotManager

  module Alexa

    module Builders

      class NewSkillManifestBuilder < SkillManifestBuilder

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

end