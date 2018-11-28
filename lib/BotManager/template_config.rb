module BotManager

  class TemplateConfig

    @account_id = nil
    @deploy_env = nil

    class << self
      attr_accessor :account_id, :deploy_env
    end

  end

end