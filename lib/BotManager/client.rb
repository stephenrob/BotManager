require 'json'
require 'BotManager/parsers'
require 'BotManager/lex/manager'
require 'BotManager/lex/slot_type'
require 'BotManager/lex/bot'
require 'BotManager/lex/intent'
require 'BotManager/lex/built_in_intent'
require 'BotManager/lex/intent_slot'
require 'BotManager/lex/code_hook_fulfillment_activity'
require 'BotManager/lex/abort_statement'
require 'BotManager/lex/conclusion_statement'
require 'BotManager/lex/value_elicitation_prompt'
require 'BotManager/lex/clarification_prompt'
require 'BotManager/alexa/manager'
require 'BotManager/alexa/manifest/privacy_and_compliance'
require 'BotManager/alexa/manifest/locale'
require 'BotManager/alexa/manifest/publishing_options'
require 'BotManager/alexa'
require 'BotManager/aws'

module BotManager

  class Client

    def initialize release, release_file, alexa_config={}
      @release = release
      @releases = JSON.parse(File.read(release_file))
      @slot_types = {}
      @slot_type_versions = {}
      @intents = {}
      @intent_versions = {}
      @bots = {}
      @bot_versions = {}
      @builtin_intents = {}
      @alexa_amazon_intents = ["AMAZON.FallbackIntent", "AMAZON.CancelIntent", "AMAZON.HelpIntent", "AMAZON.StopIntent", "AMAZON.YesIntent", "AMAZON.NoIntent"]
      @lex_valid_amazon_intents = ["AMAZON.HelpIntent"]
      @lex_manager = Lex::Manager.new
      @alexa_manager = Alexa::Manager.new alexa_config[:client_id], alexa_config[:client_secret], alexa_config[:refresh_token], alexa_config[:vendor_id]
    end

    def load_slot_type slot_type_file
      parsed_slot_type = Parsers::SlotTypeParser.new slot_type_file
      @slot_types[parsed_slot_type.name] = parsed_slot_type
    end

    def load_intent intent_file
      parsed_intent = Parsers::IntentParser.new intent_file
      if !parsed_intent.type.nil? && parsed_intent.type.start_with?('AMAZON.')
        @builtin_intents[parsed_intent.type] = parsed_intent
      else
        @intents[parsed_intent.name] = parsed_intent
      end
    end

    def load_bot bot_file
      parsed_bot = Parsers::BotParser.new bot_file
      @bots[parsed_bot.name] = parsed_bot
    end

    def register_lex_bots
      register_slot_types_with_lex
      register_intents_with_lex
      register_bots_with_lex
      alias_lex_bots
      sleep(5)
      cleanup_lex_versions
    end

    def register_alexa_bots
      register_bots_with_alexa
      register_account_linking_with_alexa
      register_interaction_model_with_alexa
    end

    def register_slot_types_with_lex

      @slot_types.each do |_key, slot_type|

        slot_type_name = generate_lex_full_name slot_type.name

        lex_slot_type = Lex::SlotType.new slot_type_name, slot_type.description

        slot_type.enumeration_values.each do |value|
          enumeration_value = Lex::EnumerationValue.new value[:value]
          if !value[:synonyms].nil?
            value[:synonyms].each do |synonym|
              enumeration_value.add_synonym synonym
            end
          end
          lex_slot_type.add_enumeration_value enumeration_value
        end

        version = @lex_manager.register_slot_type lex_slot_type

        @slot_type_versions[slot_type_name] = version

      end

    end

    def register_intents_with_lex

      @intents.each do |_key, intent|

        intent_name = generate_lex_full_name intent.name

        lex_intent = Lex::Intent.new intent_name, intent.description

        intent.sample_utterances.each do |utterance|
          lex_intent.add_sample_utterance utterance
        end

        fulfillment_activity = intent.lex[:fulfillment_activity]

        if !fulfillment_activity.nil? && !fulfillment_activity.empty?
          lex_fulfillment_activity = Lex::CodeHookFulfillmentActivity.new fulfillment_activity[:uri]
          lex_intent.set_fulfillment_activity lex_fulfillment_activity
        end

        conclusion_statement = intent.lex[:conclusion_statement]

        if !conclusion_statement.nil? && !conclusion_statement.empty?
          lex_conclusion_statement = Lex::ConclusionStatement.new
          conclusion_statement[:messages].each do |message|
            lex_conclusion_statement.add_message message[:content_type], message[:content]
          end
          lex_intent.set_conclusion_statement lex_conclusion_statement
        end

        if intent.slots.nil? || intent.slots.empty?
          puts "No slots to load for intent"
        else
          intent.slots.each do |slot|

            parsed_slot = Parsers::SlotParser.new slot

            intent_slot_name = parsed_slot.name

            if parsed_slot.type.start_with?('AMAZON')

              if parsed_slot.type == 'AMAZON.SearchQuery'

                search_slot_type_name = generate_lex_full_name 'searchQuery'

                if @slot_type_versions[search_slot_type_name].nil?

                  lex_search_slot_type = Lex::SearchQuerySlotType.new search_slot_type_name, "AMAZON.SearchQuery slot for lex"

                  lex_search_slot_version = @lex_manager.register_slot_type lex_search_slot_type

                  @slot_type_versions[search_slot_type_name] = lex_search_slot_version

                end

                intent_slot_type = search_slot_type_name

              else

                intent_slot_type = parsed_slot.type

              end

            else
              intent_slot_type = generate_lex_full_name parsed_slot.type
            end

            lex_intent_slot = Lex::IntentSlot.new intent_slot_name, parsed_slot.description

            lex_intent_slot.slot_constraint = parsed_slot.constraint
            lex_intent_slot.slot_type = intent_slot_type
            lex_intent_slot.slot_type_version = @slot_type_versions[intent_slot_type]

            parsed_slot.sample_utterances.each do |utterance|
              lex_intent_slot.add_utterance utterance
            end

            elicitation_prompt = parsed_slot.elicitation_prompt
            lex_value_elicitation_prompt = Lex::ValueElicitationPrompt.new elicitation_prompt[:max_attempts]
            elicitation_prompt[:messages].each do |message|
              lex_value_elicitation_prompt.add_message message[:content_type], message[:content]
            end

            lex_intent_slot.set_value_elicitation_prompt lex_value_elicitation_prompt

            lex_intent.register_slot lex_intent_slot

          end
        end

        version = @lex_manager.register_intent lex_intent
        @intent_versions[intent_name] = version

      end

    end

    def register_bots_with_lex

      @bots.each do |_key, bot|

        bot_name = generate_lex_full_name bot.name

        lex_bot = Lex::Bot.new bot_name, bot.description

        bot.intents.each do |intent|
          intent_name = generate_lex_full_name intent[:intent_name]
          lex_bot.register_intent intent_name, @intent_versions[intent_name]
        end

        bot.lex[:builtin_intents].each do |builtin_intent|

          next unless @lex_valid_amazon_intents.include? builtin_intent[:type]

          if @builtin_intents[builtin_intent[:type]].nil?

            intent_name = generate_lex_full_name builtin_intent[:name]

            lex_intent = Lex::BuiltInIntent.new builtin_intent[:type], intent_name

            fulfillment_activity = builtin_intent[:fulfillment_activity]

            if !fulfillment_activity.nil? && !fulfillment_activity.empty?
              lex_fulfillment_activity = Lex::CodeHookFulfillmentActivity.new fulfillment_activity[:uri]
              lex_intent.set_fulfillment_activity lex_fulfillment_activity
            end

            version = @lex_manager.register_intent lex_intent

            lex_bot.register_intent intent_name, version

          else

            custom_builtin_intent = @builtin_intents[builtin_intent[:type]]

            intent_name = generate_lex_full_name custom_builtin_intent.name

            lex_intent = Lex::BuiltInIntent.new builtin_intent[:type], intent_name

            fulfillment_activity = custom_builtin_intent.lex[:fulfillment_activity]

            if !fulfillment_activity.nil? && !fulfillment_activity.empty?
              lex_fulfillment_activity = Lex::CodeHookFulfillmentActivity.new fulfillment_activity[:uri]
              lex_intent.set_fulfillment_activity lex_fulfillment_activity
            end

            version = @lex_manager.register_intent lex_intent

            lex_bot.register_intent intent_name, version

          end

        end

        sleep 5

        bot.aws_qna_intents.each do |qna_intent|

          aws_qna_intent = Aws::QnaBot.new qna_intent[:qna_bot_name], qna_intent[:qna_bot_version]

          slot_type_name = generate_lex_full_name "#{qna_intent[:name]}SlotType"

          lex_slot_type = Lex::SlotType.new slot_type_name, "AWS QnA Bot Intent Slot"

          aws_qna_intent.get_slot_enumerations.each do |value|
            enumeration_value = Lex::EnumerationValue.new value[:value]
            if !value[:synonyms].nil?
              value[:synonyms].each do |synonym|
                enumeration_value.add_synonym synonym
              end
            end
            lex_slot_type.add_enumeration_value enumeration_value
          end

          slot_version = @lex_manager.register_slot_type lex_slot_type

          @slot_type_versions[slot_type_name] = slot_version

          intent_name = generate_lex_full_name qna_intent[:name]

          lex_intent = Lex::Intent.new intent_name, "QnA Questioning"

          lex_intent.add_sample_utterance "{#{slot_type_name}}"

          fulfillment_activity = aws_qna_intent.get_fulfillment_activity

          if !fulfillment_activity.nil? && !fulfillment_activity.empty?
            lex_fulfillment_activity = Lex::CodeHookFulfillmentActivity.new fulfillment_activity[:code_hook][:uri]
            lex_intent.set_fulfillment_activity lex_fulfillment_activity
          end

          lex_intent_slot = Lex::IntentSlot.new slot_type_name, "Question"

          lex_intent_slot.slot_type = slot_type_name
          lex_intent_slot.slot_type_version = slot_version
          lex_intent_slot.slot_constraint = "Optional"

          lex_value_elicitation_prompt = Lex::ValueElicitationPrompt.new 1
          [{:content_type => "PlainText", :content => "prompt"}].each do |message|
            lex_value_elicitation_prompt.add_message message[:content_type], message[:content]
          end

          lex_intent_slot.set_value_elicitation_prompt lex_value_elicitation_prompt

          lex_intent.register_slot lex_intent_slot

          intent_version = @lex_manager.register_intent lex_intent

          @intent_versions[intent_name] = intent_version

          lex_bot.register_intent intent_name, intent_version

        end

        sleep 5

        lex_bot.idle_session_ttl_in_seconds = bot.lex[:idle_session_ttl_in_seconds]
        lex_bot.voice_id = bot.lex[:voice_id]
        lex_bot.locale = bot.lex[:locale]
        lex_bot.child_directed = bot.privacy_and_compliance[:isChildDirected]

        abort_statement = bot.lex[:abort_statement]
        clarification_statement = bot.lex[:clarification_statement]

        if !abort_statement.nil? && !abort_statement.empty?
          lex_abort_statement = Lex::AbortStatement.new
          abort_statement[:messages].each do |message|
            lex_abort_statement.add_message message[:content_type], message[:content]
          end
          lex_bot.set_abort_statement lex_abort_statement
        end

        if !clarification_statement.nil? && !clarification_statement.empty?
          lex_clarification_statement = Lex::ClarificationPrompt.new clarification_statement[:max_attempts]
          clarification_statement[:messages].each do |message|
            lex_clarification_statement.add_message message[:content_type], message[:content]
          end
          lex_bot.set_clarification_prompt lex_clarification_statement
        end

        version = @lex_manager.register_bot lex_bot
        @bot_versions[bot_name] = version

      end

    end

    def alias_lex_bots

      @bots.each do |_key, bot|

        bot_name = generate_lex_full_name bot.name

        bot_version = @bot_versions[bot_name]

        bot_alias = get_current_release_data["alias"]

        @lex_manager.update_bot_alias bot_name, bot_version, bot_alias

      end

    end

    def cleanup_lex_versions

      max_versions_to_keep = 5

      puts "Cleaning up lex versions"

      @bots.each do |_key, bot|

        bot_name = generate_lex_full_name bot.name

        puts "Cleaning up versions on bot: #{bot_name}"

        @lex_manager.cleanup_bot_versions bot_name, max_versions_to_keep, ["$LATEST", @bot_versions[bot_name]]

      end

      @intents.each do |_key, intent|

        intent_name = generate_lex_full_name intent.name

        puts "Cleaning up versions on intent: #{intent_name}"

        @lex_manager.cleanup_intent_versions intent_name, max_versions_to_keep, ["$LATEST", @intent_versions[intent_name]]

      end

      @slot_types.each do |_key, slot_type|

        slot_type_name = generate_lex_full_name slot_type.name

        puts "Cleaning up versions on slot type: #{slot_type_name}"

        @lex_manager.cleanup_slot_type_versions slot_type_name, max_versions_to_keep, ["$LATEST", @slot_type_versions[slot_type_name]]

      end

      puts "Finished cleaning up lex versions"

    end

    def register_bots_with_alexa

      @bots.each do |_key, bot|

        bot_full_name = generate_bot_full_name bot.name

        privacy_and_compliance = BotManager::Alexa::Manifest::PrivacyAndCompliance.new

        privacy_and_compliance.allows_purchases = bot.privacy_and_compliance[:allowsPurchases]
        privacy_and_compliance.uses_personal_info = bot.privacy_and_compliance[:usesPersonalInfo]
        privacy_and_compliance.is_child_directed = bot.privacy_and_compliance[:isChildDirected]
        privacy_and_compliance.is_export_compliant = bot.privacy_and_compliance[:isExportCompliant]
        privacy_and_compliance.contains_ads = bot.privacy_and_compliance[:containsAds]

        locale = BotManager::Alexa::Manifest::Locale.new bot.alexa[:locale], bot_full_name, bot.description

        locale.terms_of_use_url = bot.privacy_and_compliance[:termsOfUseUrl]
        locale.privacy_policy_url = bot.privacy_and_compliance[:privacyPolicyUrl]
        locale.small_icon_uri = bot.alexa[:smallIconUri]
        locale.large_icon_uri = bot.alexa[:largeIconUri]
        locale.summary = bot.alexa[:summary]

        bot.alexa[:examplePhrases].each do |phrase|
          locale.add_example_phrase phrase
        end

        bot.alexa[:keywords].each do |keyword|
          locale.add_keyword keyword
        end

        privacy_and_compliance.add_locale locale

        publishing_options = BotManager::Alexa::Manifest::PublishingOptions.new

        publishing_options.is_available_worldwide = bot.alexa[:isAvailableWorldwide]
        publishing_options.testing_instructions = bot.alexa[:testingInstructions]
        publishing_options.category = bot.alexa[:category]
        publishing_options.distribution_mode = bot.alexa[:distributionMode]

        endpoint = bot.alexa[:endpoint]

        @alexa_manager.register_skill bot_full_name, privacy_and_compliance, locale, publishing_options, endpoint

      end

      @alexa_manager.reload_skills

    end

    def register_account_linking_with_alexa

      @bots.each do |_key, bot|

        if bot.alexa[:accountLinking].nil? || bot.alexa[:accountLinking].empty?
          puts 'Not linking account - no account linking data present'
          return
        end

        skill_id = @alexa_manager.get_skill_id_from_name generate_bot_full_name(bot.name)

        if skill_id.nil? || skill_id.empty?
          puts 'No skill for bot name'
          puts 'Not linking account as bot doesnot exist'
          return
        end

        account_linking_data = bot.alexa[:accountLinking]

        account_linking = BotManager::Alexa::Builders::AccountLinkingRequestBuilder.new

        account_linking_data[:domains].each do |domain|
          account_linking.add_domain domain
        end

        account_linking_data[:scopes].each do |scope|
          account_linking.add_scope scope
        end

        account_linking.skip_on_enablement = account_linking_data[:skipOnEnablement]
        account_linking.type = account_linking_data[:type]
        account_linking.authorization_url = account_linking_data[:authorizationUrl]
        account_linking.client_id = account_linking_data[:clientId]
        account_linking.client_secret = account_linking_data[:clientSecret]
        account_linking.access_token_url = account_linking_data[:accessTokenUrl]
        account_linking.access_token_scheme = account_linking_data[:accessTokenScheme]
        account_linking.default_token_expiration_in_seconds = account_linking_data[:defaultTokenExpirationInSeconds]

        @alexa_manager.register_skill_account_linking skill_id, account_linking

      end

    end

    def register_interaction_model_with_alexa

      prompts = {}

      dialog_intents = {}
      dialog_slots = {}

      language_intents = {}
      language_slots = {}
      language_types = {}

      intent_prompts = {}

      @slot_types.each do |_key, slot_type|

        type = BotManager::Alexa::LanguageModel::Type.new slot_type.name

        slot_type.enumeration_values.each do |enum|
          type.add_value enum[:value], enum[:synonyms]
        end

        language_types[slot_type.name] = type

      end

      @intents.each do |_key, bot_intent|

        name = bot_intent.name

        puts "Intent: #{name}"

        language_intent = BotManager::Alexa::LanguageModel::Intent.new name
        dialog_intent = BotManager::Alexa::Dialog::Intent.new name, false
        intent_prompts[name] = []

        if bot_intent.slots.nil? || bot_intent.slots.empty?

          puts 'No slots to load for intent'

        else

          bot_intent.slots.each do |intent_slot|

            slot = BotManager::Parsers::SlotParser.new intent_slot

            if language_slots.keys.include?(slot.name) && dialog_slots.keys.include?(slot.name)
              dialog_intent.add_slot dialog_slots[slot.name]
              language_intent.add_slot language_slots[slot.name]
              next
            end

            dialog_slot = BotManager::Alexa::Dialog::Slot.new slot.name, slot.type, slot.alexa[:confirmation_required], slot.alexa[:elicitation_required]
            language_slot = BotManager::Alexa::LanguageModel::Slot.new slot.name, slot.type

            slot.sample_utterances.each do |utterance|
              language_slot.add_sample utterance
            end

            if !slot.elicitation_prompt.nil? && !slot.elicitation_prompt.empty?

              elicitation_prompt = BotManager::Alexa::Prompt::SlotElicitation.new bot_intent.name, slot.name

              slot.elicitation_prompt[:messages].each do |elicitation_message|

                elicitation_prompt.add_variation elicitation_message[:content_type], elicitation_message[:content]

              end

              prompts[elicitation_prompt.id] = elicitation_prompt
              intent_prompts[name].append elicitation_prompt.id

              dialog_slot.set_elicitation elicitation_prompt

            end

            if !slot.alexa[:validation].nil? && !slot.alexa[:validation].empty?

              validation = slot.alexa[:validation]

              slot_validation_prompt = BotManager::Alexa::Prompt::SlotValidation.new bot_intent.name, slot.name

              validation[:prompt][:variations].each do |variation|
                slot_validation_prompt.add_variation variation[:type], variation[:value]
              end

              slot_validation = BotManager::Alexa::Dialog::SlotValidation.new validation[:type]

              slot_validation.set_validation_prompt slot_validation_prompt

              if !validation[:values].nil? && !validation[:values].empty?
                validation[:values].each do |value|
                  slot_validation.add_value value
                end
              end

              prompts[slot_validation_prompt.id] = slot_validation_prompt
              intent_prompts[name].append slot_validation_prompt.id

              dialog_slot.add_validation slot_validation

            end

            language_slots[slot.name] = language_slot
            dialog_slots[slot.name] = dialog_slot

            dialog_intent.add_slot dialog_slot
            language_intent.add_slot language_slot

          end

        end

        if bot_intent.sample_utterances.nil? || bot_intent.sample_utterances.empty?

          puts 'No sample uterrances for intent'

        else

          bot_intent.sample_utterances.each do |utterance|
            language_intent.add_sample utterance
          end

        end

        language_intents[name] = language_intent
        dialog_intents[name] = dialog_intent

      end

      @alexa_amazon_intents.each do |intent_name|

        language_intent = BotManager::Alexa::LanguageModel::Intent.new intent_name

        if !@builtin_intents[intent_name].nil?

          custom_builtin_intent = @builtin_intents[intent_name]

          custom_builtin_intent.sample_utterances.each do |utterance|
            language_intent.add_sample utterance
          end
        end

        language_intents[intent_name] = language_intent

      end

      @bots.each do |_key, bot|

        skill_id = @alexa_manager.get_skill_id_from_name generate_bot_full_name(bot.name)

        if skill_id.nil? || skill_id.empty?
          puts 'No skill for bot name'
          puts 'Not linking account as bot does not exist'
          next
        end

        interaction_model = BotManager::Alexa::Builders::InteractionModelBuilder.new
        language_model = BotManager::Alexa::LanguageModel::Builder.new bot.alexa[:invocation_name]
        dialog_model = BotManager::Alexa::Dialog::Builder.new

        bot.intents.each do |bot_intent|

          dialog_intent = dialog_intents[bot_intent[:intent_name]]
          language_intent = language_intents[bot_intent[:intent_name]]

          if dialog_intent.nil?
            puts 'Failed to add dialog intent to bot, dialog intent does not exist'
          else
            dialog_model.register_intent dialog_intent
          end

          if language_intent.nil?
            puts 'Failed to add language intent to bot, language intent does not exist'
          else
            language_model.register_intent language_intent
          end

          language_intent.slots.each do |language_slot|

            type = language_slot[:type]

            language_type = language_types[type]

            language_model.register_type language_type

          end

          intent_prompts[bot_intent[:intent_name]].each do |intent_prompt_id|

            interaction_model.register_prompt prompts[intent_prompt_id]

          end

        end

        bot.aws_qna_intents.each do |qna_intent|

          aws_qna_intent = Aws::QnaBot.new qna_intent[:qna_bot_name], qna_intent[:qna_bot_version]

          name = qna_intent[:name]

          slot_type_name = "#{name}SlotType"

          type = BotManager::Alexa::LanguageModel::Type.new slot_type_name

          aws_qna_intent.get_slot_enumerations.each do |enum|
            type.add_value enum[:value], enum[:synonyms]
          end

          language_types[slot_type_name] = type

          language_intent = BotManager::Alexa::LanguageModel::Intent.new name
          dialog_intent = BotManager::Alexa::Dialog::Intent.new name, false
          intent_prompts[name] = []

          slot_name = "#{name}Slot"

          dialog_slot = BotManager::Alexa::Dialog::Slot.new slot_name, slot_type_name, false, true
          language_slot = BotManager::Alexa::LanguageModel::Slot.new slot_name, slot_type_name

          language_intent.add_sample "{#{slot_name}}"

          elicitation_prompt = BotManager::Alexa::Prompt::SlotElicitation.new name, slot_name

          elicitation_prompt.add_variation "PlainText", "prompt"

          prompts[elicitation_prompt.id] = elicitation_prompt
          intent_prompts[name].append elicitation_prompt.id

          dialog_slot.set_elicitation elicitation_prompt

          language_slots[slot_name] = language_slot
          dialog_slots[slot_name] = dialog_slot

          dialog_intent.add_slot dialog_slot
          language_intent.add_slot language_slot

          language_intents[name] = language_intent
          dialog_intents[name] = dialog_intent

          dialog_model.register_intent dialog_intent
          language_model.register_intent language_intent

          language_intent.slots.each do |lang_slot|

            type = lang_slot[:type]

            language_type = language_types[type]

            language_model.register_type language_type

          end

          interaction_model.register_prompt prompts[elicitation_prompt.id]

        end

        @alexa_amazon_intents.each do |intent_name|

          language_intent = language_intents[intent_name]

          language_model.register_intent language_intent

        end

        interaction_model.add_dialog dialog_model
        interaction_model.add_language_model language_model

        @alexa_manager.register_skill_interaction_model skill_id, interaction_model, 'en-GB'

      end

    end

    def generate_bot_full_name name

      release_data = get_current_release_data

      skill_suffix = release_data["skill_suffix"]

      if skill_suffix.nil? || skill_suffix.empty?
        return name
      end

      "#{name} - #{skill_suffix}"

    end

    def generate_lex_full_name name

      formatted_name = name.gsub(/\s+/, '')

      formatted_name = formatted_name.gsub(/\./, '')

      release_data = get_current_release_data

      skill_suffix = release_data["lex_suffix"]

      if skill_suffix.nil? || skill_suffix.empty?
        return formatted_name
      end

      "#{formatted_name}#{skill_suffix}".gsub(/\s+/, '')

    end

    def get_current_release_data
      @releases[@release]
    end

    def get_lex_bot_versions
      @bot_versions
    end

  end

end