module BotManager

  class TemplateConfig

    @account_id = nil
    @deploy_env = nil
    @account_linking_authorization_url = nil
    @account_linking_client_id = nil
    @account_linking_client_secret = nil
    @account_linking_access_token_url = nil

    class << self
      attr_accessor :account_id, :deploy_env, :account_linking_authorization_url, :account_linking_client_id, :account_linking_client_secret, :account_linking_access_token_url
    end

  end

end