module BotManager

  module Alexa

    module Api

      module Endpoints

        module SkillManagement

          def get_skills vendor_id, skill_ids=[], max_results=nil, next_token=nil

            endpoint = "/v1/skills?vendorId=#{vendor_id}"

            if (!skill_ids.nil? && !skill_ids.empty?) && skill_ids.length < 10

              skill_ids_param = ''

              skill_ids.each do |id|
                param = "skillId=#{id}"
                skill_ids_param += "&#{param}"
              end

              endpoint += "#{skill_ids_param}"

            end

            if (skill_ids.nil? || skill_ids.empty?) && (!max_results.nil? && !max_results.to_s.empty?)
              endpoint += "&maxResults=#{max_results}"
            end

            if (skill_ids.nil? || skill_ids.empty?) && (!next_token.nil? && !next_token.empty?)
              endpoint += "&nextToken=#{next_token}"
            end

            get(endpoint)
          end

          def get_skill skill_id, stage='development'

            endpoint = "/v1/skills/#{skill_id}/stages/#{stage}/manifest"

            get(endpoint)

          end

          def create_skill vendor_id, manifest

            endpoint = '/v1/skills'

            body = {
                "vendorId": vendor_id,
            }.merge(manifest)

            post(endpoint, {body: body.to_json})

          end

          def update_skill skill_id, manifest

            endpoint = "/v1/skills/#{skill_id}/stages/development/manifest"

            put(endpoint, {body: manifest.to_json})

          end

          def get_skill_resource_status skill_id, resource='manifest'

            endpoint = "/v1/skills/#{skill_id}/status?resource=#{resource}"

            get(endpoint)

          end

          def delete_skill skill_id

            endpoint = "/v1/skills/#{skill_id}"

            delete(endpoint)

          end

        end

      end

    end

  end

end