module BotManager

  module Alexa

    module Api

      module Endpoints

        module AccountLinkingManagement

          def get_account_linking_information skill_id, stage='development'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/accountLinkingClient"

            get(endpoint)

          end

          def update_account_linking skill_id, body, stage='development'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/accountLinkingClient"

            put(endpoint, {body: body})

          end

          def delete_account_linking_partner skill_id

            endpoint = "/v1/skills/#{skill_id}/stages/development/accountLinkingClient"

            delete(endpoint)

          end

        end

      end

    end

  end

end