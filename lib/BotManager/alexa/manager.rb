require 'BotManager/alexa/api/client'
require 'BotManager/alexa/builders/skill_manifest_builder'
require 'BotManager/alexa/builders/new_skill_manifest_builder'
require 'aws-sdk-lambda'

module BotManager

  module Alexa

    class Manager

      def initialize client_id, client_secret, refresh_token, vendor_id
        @client = Api::Client.new client_id, client_secret, refresh_token
        @lambda = Aws::Lambda::Client.new
        @vendor_id = vendor_id
        @skills = {}
        pre_load_skills
      end

      def register_skill name, privacy_and_compliance, locale, publishing_options, endpoint

        if @skills.keys.include? name

          puts "Skill exists - updating"

          skill_id = @skills[name]

          update_skill skill_id, privacy_and_compliance, locale, publishing_options, endpoint

        else

          puts "Skill does not exist - creating"

          create_new_skill privacy_and_compliance, locale, publishing_options, endpoint

        end

        reload_skills

      end

      def register_skill_interaction_model skill_id, interaction_model, model_locale='en-US'

        @client.update_interaction_model skill_id, interaction_model.to_h, 'development', model_locale

      end

      def register_skill_account_linking skill_id, account_linking

        @client.update_account_linking skill_id, account_linking.to_h

      end

      def get_skill_id_from_name name

        @skills[name]

      end

      def reload_skills
        pre_load_skills
      end

      private

      def create_new_skill privacy_and_compliance, locale, publishing_options, endpoint

        manifest = Builders::NewSkillManifestBuilder.new

        manifest.add_privacy_and_compliance privacy_and_compliance
        manifest.register_locale locale
        manifest.register_publishing_options publishing_options

        create_skill_response = @client.create_skill @vendor_id, manifest.to_h

        skill_id = JSON.parse(create_skill_response.body)["skillId"]

        wait_loop = 0
        exceeded_max_retries = false
        skill_status = nil

        until skill_status == 'SUCCEEDED' || exceeded_max_retries

          puts 'Waiting for bot to be created'

          sleep(2**wait_loop)

          skill_status_response = @client.get_skill_resource_status skill_id

          skill_status = last_update_status(skill_status_response.body)

          wait_loop += 1

          exceeded_max_retries = wait_loop > 7

        end

        if skill_status == 'SUCCEEDED'
          puts 'Bot created successfully'
        elsif exceeded_max_retries
          puts "Exceeded max retries for skill status. Last returned skill status #{skill_status}"
          return
        else
          puts "Skill status of #{skill_status} returned"
          return
        end

        if !endpoint.nil? && !endpoint.empty?
          add_skill_lambda_permission endpoint, skill_id
        end

        sleep(20)

        update_skill skill_id, privacy_and_compliance, locale, publishing_options, endpoint

      end

      def update_skill skill_id, privacy_and_compliance, locale, publishing_options, endpoint

        manifest = Builders::SkillManifestBuilder.new

        manifest.register_endpoint endpoint
        manifest.add_privacy_and_compliance privacy_and_compliance
        manifest.register_locale locale
        manifest.register_publishing_options publishing_options

        @client.update_skill skill_id, manifest.to_h

      end

      def add_skill_lambda_permission function, skill_id
        @lambda.add_permission({
                                   function_name: function,
                                   statement_id: 'BotManagerAlexaSkillsKitAccess',
                                   action: 'lambda:InvokeFunction',
                                   principal: 'alexa-appkit.amazon.com',
                                   event_source_token: skill_id
                               })
      end

      def last_update_status response_body

        JSON.parse(response_body)["manifest"]["lastUpdateRequest"]["status"]

      end

      def pre_load_skills locale='en-GB', next_token=nil

        response = @client.get_skills @vendor_id, [], 10, next_token

        body = JSON.parse(response.body)
        skills = body['skills']
        next_token = body['nextToken']

        skills.each do |skill|
          @skills[skill['nameByLocale'][locale]] = skill['skillId']
        end

        unless next_token.nil? || next_token.empty?
          pre_load_skills locale, next_token
        end

      end

    end

  end

end