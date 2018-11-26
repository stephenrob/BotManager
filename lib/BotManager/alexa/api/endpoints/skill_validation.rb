module BotManager

  module Alexa

    module Api

      module Endpoints

        module SkillValidation

          def validate_skill skill_id, locales=[] stage='development'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/validations"

            if locales.nil? || locales.empty?
              locales = ['en-US']
            end

            body = {
                locales: locales
            }

            post(endpoint, {body: body})

          end

          def get_skill_validation skill_id, validation_id, stage='development'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/validations/#{validation_id}"

            get(endpoint)

          end

        end

      end

    end

  end

end