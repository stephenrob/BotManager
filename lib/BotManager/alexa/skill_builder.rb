require 'BotManager/alexa/builders'
require 'BotManager/alexa/manifest'

module BotManager

  module Alexa

    class SkillBuilder

      attr_reader :bot_manifest

      def initialize bot_parser
        @bot_parser = bot_parser
      end

      def build_full_manifest_file

        build_manifest_file :full

      end

      def build_new_manifest_file

        build_manifest_file :new

      end

      def build_manifest_file type = :full

        case type
        when :full
          manifest_builder = Builders::SkillManifestBuilder
        when :new
          manifest_builder = Builders::NewSkillManifestBuilder
        else
          manifest_builder = Builders::SkillManifestBuilder
        end

        privacy_and_compliance = build_privacy_and_compliance

        endpoint = build_endpoint

        locale = build_locale

        privacy_and_compliance.add_locale locale

        publishing_options = build_publishing_options

        manifest_builder.add_privacy_and_compliance privacy_and_compliance
        manifest_builder.register_locale locale
        manifest_builder.register_publishing_options publishing_options
        manifest_builder.register_endpoint endpoint

        @bot_manifest = manifest_builder.to_h

      end

      private

      def build_endpoint
        @bot_parser.alexa[:endpoint]
      end

      def build_privacy_and_compliance

        privacy_and_compliance = Manifest::PrivacyAndCompliance.new

        privacy_and_compliance.allows_purchases = @bot_parser.privacy_and_compliance[:allows_purchases]
        privacy_and_compliance.uses_personal_info = @bot_parser.privacy_and_compliance[:uses_personal_info]
        privacy_and_compliance.is_child_directed = @bot_parser.privacy_and_compliance[:is_child_directed]
        privacy_and_compliance.is_export_compliant = @bot_parser.privacy_and_compliance[:is_export_compliant]
        privacy_and_compliance.contains_ads = @bot_parser.privacy_and_compliance[:contains_ads]

        privacy_and_compliance

      end

      def build_locale

        locale = Manifest::Locale.new @bot_parser.alexa[:locale], @bot_parser.name, @bot_parser.description

        locale.terms_of_use_url = @bot_parser.privacy_and_compliance[:terms_of_use_url]
        locale.privacy_policy_url = @bot_parser.privacy_and_compliance[:privacy_policy_url]
        locale.small_icon_uri = @bot_parser.alexa[:small_icon_uri]
        locale.large_icon_uri = @bot_parser.alexa[:large_icon_uri]
        locale.summary = @bot_parser.alexa[:summary]

        locale

      end

      def build_publishing_options

        publishing_options = Manifest::PublishingOptions.new

        publishing_options.is_available_worldwide = @bot_parser.alexa[:is_available_worldwide]
        publishing_options.testing_instructions = @bot_parser.alexa[:testing_instructions]
        publishing_options.category = @bot_parser.alexa[:category]

        publishing_options

      end

    end

  end

end