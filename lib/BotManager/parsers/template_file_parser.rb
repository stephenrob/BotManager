require 'BotManager/template_config'

module BotManager

  module Parsers

    class TemplateFileParser

      def self.parse file_path

        template_file = File.read(file_path)

        file = template_file.gsub('${ACCOUNT_ID}', BotManager::TemplateConfig.account_id)
        file = file.gsub('${DEPLOY_ENV}', BotManager::TemplateConfig.deploy_env)
        file = file.gsub('${ACCOUNT_LINKING_AUTHORIZATION_URL}', BotManager::TemplateConfig.account_linking_authorization_url)
        file = file.gsub('${ACCOUNT_LINKING_CLIENT_ID}', BotManager::TemplateConfig.account_linking_client_id)
        file = file.gsub('${ACCOUNT_LINKING_CLIENT_SECRET}', BotManager::TemplateConfig.account_linking_client_secret)
        file = file.gsub('${ACCOUNT_LINKING_ACCESS_TOKEN_URL}', BotManager::TemplateConfig.account_linking_access_token_url)
        file = file.gsub('${QNA_ID}', BotManager::TemplateConfig.qna_id)
        file = file.gsub('${QNA_BOT_NAME}', BotManager::TemplateConfig.qna_bot_name)
        file = file.gsub('${QNA_BOT_VERSION}', BotManager::TemplateConfig.qna_bot_version)
        file = file.gsub('${BOT_NAME}', BotManager::TemplateConfig.bot_name)

        file

      end

    end

  end

end