require 'json'
require 'BotManager/parsers'
require 'BotManager/lex/manager'
require 'BotManager/lex/slot_type'
require 'BotManager/lex/bot'
require 'BotManager/lex/intent'
require 'BotManager/lex/intent_slot'
require 'BotManager/lex/code_hook_fulfillment_activity'
require 'BotManager/lex/abort_statement'
require 'BotManager/lex/conclusion_statement'
require 'BotManager/lex/value_elicitation_prompt'
require 'BotManager/lex/clarification_prompt'

module BotManager

  class Client

    def initialize release_file
      @releases = JSON.parse(File.read(release_file))
      @slot_types = []
      @intents = []
      @bots = []
      @lex_manager = Lex::Manager.new
    end

    def load_slot_type slot_type_file
      parsed_slot_type = Parsers::SlotTypeParser.new slot_type_file
      @slot_types.append parsed_slot_type
    end

    def load_intent intent_file
      parsed_intent = Parsers::IntentParser.new intent_file
      @intents.append parsed_intent
    end

    def load_bot bot_file
      parsed_bot = Parsers::BotParser.new bot_file
      @bots.append parsed_bot
    end

    def register_slot_types_with_lex

      @slot_types.each do |slot_type|

        lex_slot_type = Lex::SlotType.new slot_type.name, slot_type.description

        slot_type.enumeration_values.each do |value|
          enumeration_value = Lex::EnumerationValue.new value[:name]
          value[:synonyms].each do |synonym|
            enumeration_value.add_synonym synonym
          end
          lex_slot_type.add_enumeration_value enumeration_value
        end

        @lex_manager.register_slot_type lex_slot_type

      end

    end

    def register_intents_with_lex

      @intents.each do |intent|

        lex_intent = Lex::Intent.new intent.name, intent.description

        intent.sample_uterrances.each do |utterance|
          lex_intent.add_sample_utterance utterance
        end

        fulfillment_activity = intent.lex[:fulfillment_activity]

        if !fulfillment_activity.nil? && !fulfillment_activity.empty?
          lex_fulfillment_activity = Lex::CodeHookFulfillmentActivity.new fulfillment_activity[:uri]
          lex_intent.set_fulfillment_activity lex_fulfillment_activity
        end

        conclusion_statement = intent.lex[:conclusion_statement]

        if !conclusion_statement.nil? || !conclusion_statement.empty?
          lex_conclusion_statement = Lex::ConclusionStatement.new
          conclusion_statement[:messages].each do |message|
            lex_conclusion_statement.add_message message[:content_type], message[:content]
          end
          lex_intent.set_conclusion_statement lex_conclusion_statement
        end

        intent.slots.each do |slot|
          parsed_slot = Parsers::SlotParser.new slot

          lex_intent_slot = Lex::IntentSlot.new parsed_slot.name, parsed_slot.description

          lex_intent_slot.slot_constraint = parsed_slot.constraint
          lex_intent_slot.slot_type = parsed_slot.type
          lex_intent_slot.slot_type_version = parsed_slot[:lex][:type_version]

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

        @lex_manager.register_intent lex_intent

      end

    end

    def register_bots_with_lex

      @bots.each do |bot|

        lex_bot = Lex::Bot.new bot.name, bot.description

        bot.intents do |intent|
          lex_bot.register_intent intent[:intent_name], intent[:intent_version]
        end

        lex_bot.idle_session_ttl_in_seconds = bot.lex[:idle_session_ttl_in_seconds]
        lex_bot.voice_id = bot.lex[:voice_id]
        lex_bot.locale = bot.lex[:locale]
        lex_bot.child_directed = bot.privacy_and_compliance[:is_child_directed]

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

        @lex_manager.register_bot lex_bot

      end

    end

  end

end