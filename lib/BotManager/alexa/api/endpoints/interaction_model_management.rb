module BotManager

  module Alexa

    module Api

      module Endpoints

        module InteractionModelManagement

          def get_interaction_model skill_id, stage='development', locale='en-US'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/interactionModel/locales/#{locale}"

            get(endpoint)

          end

          def update_interaction_model skill_id, manifest, stage='development', locale='en-US'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/interactionModel/locales/#{locale}"

            put(endpoint, {body: manifest})

          end

        end

      end

    end

  end

end