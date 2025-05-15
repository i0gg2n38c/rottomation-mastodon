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

      def self.lookup_account_request(logger:, username:)
        req = Rottomation::HttpRequestBuilder.new(url: "#{ACCOUNTS_URL}/lookup", method_type: :get)
                                             .with_url_param('acct', username)
                                             .with_header('accept', 'application/json')
                                             .build
        execute_request(logger: logger, request: req)
      end

      def self.verify_credentials_request(logger:, auth_context:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/verify_credentials", method_type: :get)
                                          .with_header('Authorization', auth_context.token)
                                          .build

        execute_request(logger: logger, request: req)
      end

      def self.update_credentials_request(logger:, auth_context:, updated_credentials:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/update_credentials", method_type: :patch)
                                          .with_header('Authorization', auth_context.token)
                                          .with_form_body(updated_credentials)
                                          .build

        execute_request(logger: logger, request: req)
      end

      def self.get_account_request(logger:, auth_context:, id:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}", method_type: :get)
                                          .with_header('Authorization', auth_context.token)
                                          .build

        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_request(logger:, auth_context:, ids:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/", method_type: :get)
                                          .with_header('Authorization', auth_context.token)
                                          .with_url_param('id[]', ids)
                                          .build

        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_statuses_request(logger:, auth_context:, id:, params: nil)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/statuses", method_type: :get)
                                          .with_header('Authorization', auth_context.token)
                                          .with_url_params(params, condition_to_include: !params.nil?)
                                          .build

        execute_request(logger: logger, request: req)
      end

      ##################################################################################################################
      # SECTION: Processing ############################################################################################
      ##################################################################################################################

      # Registers an account to the Instance using the provided user form data.
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext]
      # @param new_user_form_data [CreateAccountFormBuilder]
      # @return [Rottomation::AuthContext]
      def self.register_account(logger:, auth_context:, new_user_form_data:)
        resp = register_account_request(logger: logger, auth_context: auth_context,
                                        new_user_form_data: new_user_form_data)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Rottomation::AuthContext.new(username: new_user_form_data[:email], password: new_user_form_data[:password])
                                .with_token(token: "Bearer #{resp.parse_body_as_json[:access_token]}")
      end

      # Looks up an account with the provided username.
      # @param logger [RottomationLogger]
      # @param username [String] username of the user we are looking up
      # @return [Mastodon::Entity::Account] matched account
      def self.lookup_account(logger:, username:)
        resp = lookup_account_request(logger: logger, username: username)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
      end

      # Verifies a user's Bearer auth token is valid
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the user who's credentials and account state we
      # are validating
      # @return [Mastodon::Entity::Accoun]
      def self.verify_credentials(logger:, auth_context:)
        resp = verify_credentials_request(logger: logger, auth_context: auth_context)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
      end

      # Updates the user entity with the provided values
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the user who's credentials we are upadting
      # @param updated_credentials [Hash] request object generated by AccountService::UpdateCredentialsBuilder
      # @return [Mastodon::Entity::Account] updated Account entity
      def self.update_credentials(logger:, auth_context:, updated_credentials:)
        resp = update_credentials_request(logger: logger, auth_context: auth_context,
                                          updated_credentials: updated_credentials)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
      end

      # Fetches the user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] id of the user we are fetching
      # @return [Mastodon::Entity::Account] matched Account entity
      def self.get_account(logger:, auth_context:, id:)
        resp = get_account_request(logger: logger, auth_context: auth_context, id: id)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
      end

      # Fetches the user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [Array<int>] ids of the user we are fetching
      # @return [Mastodon::Entity::Account] matched Account entities
      def self.get_accounts(logger:, auth_context:, ids:)
        resp = get_accounts_request(logger: logger, auth_context: auth_context, ids: ids)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |account| Entity::Account.new(account) }
      end

      # Fetches the user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] ids of the user whose statuses we are fetching
      # @param params [Hash] params to provide to the request. Build from GetStatusParamBuilder
      # @return [Mastodon::Entity::Status] statuses for the provided user
      def self.get_accounts_statuses(logger:, auth_context:, id:, params: nil)
        resp = get_accounts_statuses_request(logger: logger, auth_context: auth_context, id: id, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |status| Entity::Status.new(status) }
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
      class CreateAccountFormBuilder < Rottomation::HttpRequestBodyBuilder
        REQUIRED_FORM_DATA_BOOL_PARAM = %w[agreement].freeze
        REQUIRED_FORM_DATA_STRING_PARAMS = %w[username email password locale].freeze
        OPTIONAL_FORM_DATA_STRING_PARAMS = %w[reason date_of_birth reason].freeze
        ALL_PARAMS = REQUIRED_FORM_DATA_STRING_PARAMS + OPTIONAL_FORM_DATA_STRING_PARAMS + REQUIRED_FORM_DATA_BOOL_PARAM
        REQUIRED_PARAMS = REQUIRED_FORM_DATA_BOOL_PARAM + REQUIRED_FORM_DATA_STRING_PARAMS

        construct_methods_and_readers(bool_params: REQUIRED_FORM_DATA_BOOL_PARAM,
                                      non_bool_params: REQUIRED_FORM_DATA_STRING_PARAMS + OPTIONAL_FORM_DATA_STRING_PARAMS)

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

      # Patch request for accounts/update_credentials endpoint
      class UpdateCredentialsBuilder < Rottomation::HttpRequestBodyBuilder
        # Fields found in documentation but not yet on an official release version just yet
        # attribution_domains - slated for 4.4.0
        NOT_YET_IMPLEMENTED_FIELDS = %w[attribution_domains].freeze

        FORM_FIELDS = %w[display_name note avatar header fields_attributes].freeze
        BOOL_FORM_FIELDS = %w[locked bot discoverable hide_collections indexable].freeze
        ALL_FIELDS = FORM_FIELDS + BOOL_FORM_FIELDS

        construct_methods_and_readers(bool_params: BOOL_FORM_FIELDS, non_bool_params: FORM_FIELDS)

        def build
          form_data = {}

          ALL_FIELDS.each do |param|
            next if param == 'fields_attributes'

            val = instance_variable_get("@#{param}")
            form_data[param.to_sym] = val unless val.nil?
          end

          @fields_attributes&.each do |index, hash|
            form_data["fields_attributes[#{index}][name]".to_sym] = hash[:name]
            form_data["fields_attributes[#{index}][value]".to_sym] = hash[:value]
          end

          form_data
        end
      end

      class GetStatusParamBuilder < Rottomation::HttpRequestBodyBuilder
        STRING_PARAMS = %w[max_id since_id min_id limit tagged].freeze
        BOOL_PARAMS = %w[only_media exclude_replies exclude_reblogs pinned].freeze
        ALL_PARAMS = STRING_PARAMS + BOOL_PARAMS

        construct_methods_and_readers(bool_params: BOOL_PARAMS, non_bool_params: STRING_PARAMS)

        def build
          params = {}
          ALL_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end
    end
  end
end
