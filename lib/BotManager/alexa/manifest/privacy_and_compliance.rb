module BotManager

  module Alexa

    module Manifest

      class PrivacyAndCompliance

        attr_reader :locales
        attr_accessor :allows_purchases, :uses_personal_info, :is_child_directed, :is_export_compliant, :contains_ads

        def initialize

          @allows_purchases = false
          @uses_personal_info = false
          @is_child_directed = false
          @is_export_compliant = true
          @contains_ads = false
          @locales = {}

        end

        def add_locale locale

          @locales[locale.slug] = {
              termsOfUseUrl: locale.terms_of_use_url,
              privacyPolicyUrl: locale.privacy_policy_url
          }

        end

        def to_h

          {
              allowsPurchases: @allows_purchases,
              usesPersonalInfo: @uses_personal_info,
              isChildDirected: @is_child_directed,
              isExportCompliant: @is_export_compliant,
              containsAds: @contains_ads,
              locales: @locales
          }

        end

      end

    end

  end

end