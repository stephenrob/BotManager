module BotManager

  module Alexa

    module Api

      module Endpoints

        module BetaTestManagement

          def create_beta_test skill_id, feedback_email

            endpoint = "/v1/skills/#{skill_id}/betaTest"

            post(endpoint, {body:{"feedbackEmail": feedback_email}})

          end

          def get_beta_test skill_id

            endpoint = "/v1/skills/#{skill_id}/betaTest"

            get(endpoint)

          end

          def update_beta_test skill_id, feedback_email

            endpoint = "/v1/skills/#{skill_id}/betaTest"

            put(endpoint, {body:{"feedbackEmail": feedback_email}})

          end

          def start_beta_test skill_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/start"

            post(endpoint)

          end

          def end_beta_test skill_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/end"

            post(endpoint)

          end

          def get_beta_testers skill_id, max_results=nil, next_token=nil

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers"

            if !max_results.nil? && !max_results.empty?
              endpoint += "&maxResults=#{max_results}"
            end

            if !next_token.nil? && !next_token.empty?
              endpoint += "&nextToken=#{next_token}"
            end

            get(endpoint)

          end

          def add_beta_tester skill_id, email_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/add"

            body = {
                "testers": [
                    {
                        "emailId": email_id
                    }
                ]
            }

            post(endpoint, {body: body})

          end

          def add_beta_testers skill_id, email_ids=[]

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/add"

            testers = []

            email_ids.each do |email|
              testers.append({"emailId": email})
            end

            body = {
                "testers": testers
            }

            post(endpoint, {body: body})

          end

          def remove_beta_tester skill_id, email_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/remove"

            body = {
                "testers": [
                    {
                        "emailId": email_id
                    }
                ]
            }

            post(endpoint, {body: body})

          end

          def remove_beta_testers skill_id, email_ids=[]

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/remove"

            testers = []

            email_ids.each do |email|
              testers.append({"emailId": email})
            end

            body = {
                "testers": testers
            }

            post(endpoint, {body: body})

          end

          def send_reminder_to_tester skill_id, email_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/sendReminder"

            body = {
                "testers": [
                    {
                        "emailId": email_id
                    }
                ]
            }

            post(endpoint, {body: body})

          end

          def send_reminder_to_testers skill_id, email_ids=[]

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/sendReminder"

            testers = []

            email_ids.each do |email|
              testers.append({"emailId": email})
            end

            body = {
                "testers": testers
            }

            post(endpoint, {body: body})

          end

          def request_feedback_from_tester skill_id, email_id

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/requestFeedback"

            body = {
                "testers": [
                    {
                        "emailId": email_id
                    }
                ]
            }

            post(endpoint, {body: body})

          end

          def request_feedback_from_testers skill_id, email_ids=[]

            endpoint = "/v1/skills/#{skill_id}/betaTest/testers/requestFeedback"

            testers = []

            email_ids.each do |email|
              testers.append({"emailId": email})
            end

            body = {
                "testers": testers
            }

            post(endpoint, {body: body})

          end

        end

      end

    end

  end

end