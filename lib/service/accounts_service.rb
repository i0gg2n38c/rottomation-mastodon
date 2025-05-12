# frozen_string_literal: true

module Mastodon
  module Service
    # comment
    class AccountService < MastodonService
      ACCOUNTS_URL = "#{Mastodon.instance_url}/api/v1/accounts"

      ##################################################################################################################
      # SECTION: Request ###############################################################################################
      ##################################################################################################################
      def self.register_account_request(logger:, auth_context:, new_user_form_data:)
        req = MastodonAuthedRequestBuilder.new(url: ACCOUNTS_URL, method_type: :post)
                                          .with_form_body(new_user_form_data)
                                          .with_auth(auth_context: auth_context)
                                          .build

        execute_request(logger: logger, request: req)
      end

      ##################################################################################################################
      # SECTION: Processing ############################################################################################
      ##################################################################################################################
      def self.register_account(logger:, auth_context:, new_user_form_data:)
        resp = register_account_request(logger: logger, auth_context: auth_context,
                                        new_user_form_data: new_user_form_data)
        verify_response_code(logger: logger, expected: 200, response: resp)

        resp = JSON.parse(resp.body)
        Rottomation::AuthContext.new(username: new_user_form_data[:email], password: new_user_form_data[:password])
                                .with_token(token: "Bearer #{resp['access_token']}")
      end

      ##################################################################################################################
      # SECTION: Builders ##############################################################################################
      ##################################################################################################################

      # Builder for the form body fields for registering a new account.
      # Conventionally:
      #   This endpoint is meant to be using the Bearer token for an OAuth application. But it turns out that
      #   Mastodon just needs a valid Bearer token in general. I don't think this should make any sort of weird
      #    ownership chain come into effect, because users aren't scoped together at all. But it's something to
      #    keep in mind.
      #  It's kinda funny that it works out that way but also there's no reason for it not to, I don't think
      class CreateAccountFormBuilder
        REQUIRED_FORM_DATA_BOOL_PARAM = %w[agreement].freeze
        REQUIRED_FORM_DATA_STRING_PARAMS = %w[username email password locale].freeze
        OPTIONAL_FORM_DATA_STRING_PARAMS = %w[reason date_of_birth reason].freeze
        ALL_STRING_PARAMS = REQUIRED_FORM_DATA_STRING_PARAMS + OPTIONAL_FORM_DATA_STRING_PARAMS
        REQUIRED_PARAMS = REQUIRED_FORM_DATA_BOOL_PARAM + REQUIRED_FORM_DATA_STRING_PARAMS

        ALL_STRING_PARAMS.each do |param|
          attr_reader param

          define_method("with_#{param}") do |val|
            instance_variable_set("@#{param}", val)
            self
          end

          def set_agreement(does_agree:)
            @agreement = does_agree
            self
          end

          def build
            form_data = {}

            REQUIRED_PARAMS.each do |param|
              val = instance_variable_get("@#{param}")
              raise ArgumentError, "Missing required parameter: #{param}" if val.nil?

              form_data[param.to_sym] = val
            end

            OPTIONAL_FORM_DATA_STRING_PARAMS.each do |param|
              val = instance_variable_get("@#{param}")
              next if val.nil?

              form_data[:param] = val
            end

            form_data
          end
        end
      end
    end
  end
end
