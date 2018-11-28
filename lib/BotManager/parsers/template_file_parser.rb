require 'BotManager/template_config'

module BotManager

  module Parsers

    class TemplateFileParser

      def self.parse file_path

        template_file = File.read(file_path)

        file = template_file.sub('${ACCOUNT_ID}', BotManager::TemplateConfig.account_id)
        file = file.sub('${DEPLOY_ENV}', BotManager::TemplateConfig.deploy_env)

        file

      end

    end

  end

end