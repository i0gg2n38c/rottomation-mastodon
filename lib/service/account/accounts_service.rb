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
        req = MastodonAuthedRequestBuilder.new(url: ACCOUNTS_URL, method_type: :post, auth_context: auth_context)
                                          .with_form_body(new_user_form_data)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.lookup_account_request(logger:, username:)
        req = Rottomation::HttpRequestBuilder.new(url: "#{ACCOUNTS_URL}/lookup", method_type: :get)
                                             .with_url_param('acct', username)
                                             .build
        execute_request(logger: logger, request: req)
      end

      def self.verify_credentials_request(logger:, auth_context:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/verify_credentials", method_type: :get,
                                               auth_context: auth_context)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.update_credentials_request(logger:, auth_context:, updated_credentials:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/update_credentials", method_type: :patch,
                                               auth_context: auth_context)
                                          .with_form_body(updated_credentials)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.get_account_request(logger:, auth_context:, id:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}", method_type: :get,
                                               auth_context: auth_context)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_request(logger:, auth_context:, ids:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/", method_type: :get,
                                               auth_context: auth_context)
                                          .with_url_param('id[]', ids)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_statuses_request(logger:, auth_context:, id:, params: nil)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/statuses", method_type: :get,
                                               auth_context: auth_context)
                                          .with_url_params(params, condition_to_include: !params.nil?)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_followers_request(logger:, auth_context:, id:, params: nil)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/followers", method_type: :get,
                                               auth_context: auth_context)
                                          .with_url_params(params, condition_to_include: !params.nil?)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.get_accounts_following_request(logger:, auth_context:, id:, params: nil)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/following", method_type: :get,
                                               auth_context: auth_context)
                                          .with_url_params(params, condition_to_include: !params.nil?)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.follow_account_request(logger:, auth_context:, id:, params: nil)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/follow", method_type: :post,
                                               auth_context: auth_context)
                                          .with_url_params(params, condition_to_include: !params.nil?)
                                          .build
        execute_request(logger: logger, request: req)
      end

      def self.unfollow_account_request(logger:, auth_context:, id:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ACCOUNTS_URL}/#{id}/unfollow", method_type: :post,
                                               auth_context: auth_context)
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

      # Fetches the users with the provided ids
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [Array<int>] ids of the user we are fetching
      # @return [Mastodon::Entity::Account] matched Account entities
      def self.get_accounts(logger:, auth_context:, ids:)
        resp = get_accounts_request(logger: logger, auth_context: auth_context, ids: ids)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |account| Entity::Account.new(account) }
      end

      # Fetches the statuses user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] ids of the user whose statuses we are fetching
      # @param params [Hash] Optional: params to provide to the request. Build from GetStatusParamBuilder
      # @return [Mastodon::Entity::Status] statuses for the provided user
      def self.get_accounts_statuses(logger:, auth_context:, id:, params: nil)
        resp = get_accounts_statuses_request(logger: logger, auth_context: auth_context, id: id, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |status| Entity::Status.new(status) }
      end

      # Fetches the followers of the user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] ids of the user whose statuses we are fetching
      # @param params [Hash] Optional: params to provide to the request. Build from GetFollowersParamBuilder
      # @return [List<Mastodon::Entity::Account>] followers of the given user
      def self.get_accounts_followers(logger:, auth_context:, id:, params: nil)
        resp = get_accounts_followers_request(logger: logger, auth_context: auth_context, id: id, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |follower| Entity::Account.new(follower) }
      end

      # Fetches the following of the user with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] ids of the user whose statuses we are fetching
      # @param params [Hash] Optional: params to provide to the request. Build from GetFollowersParamBuilder
      # @return [List<Mastodon::Entity::Account>] accounts followed by the given user
      def self.get_accounts_following(logger:, auth_context:, id:, params: nil)
        resp = get_accounts_following_request(logger: logger, auth_context: auth_context, id: id, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp.parse_body_as_json.map { |follower| Entity::Account.new(follower) }
      end

      # Follows the account with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] id of the user whom is being followed 😈
      # @param params [Hash] Optional: params to provide to the request. Build from FollowUserParamBulder
      # @return [Mastodon::Entity::Account] account followed by the given user
      def self.follow_account(logger:, auth_context:, id:, params: nil)
        resp = follow_account_request(logger: logger, auth_context: auth_context, id: id, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
      end

      # Follows the account with the provided id
      # @param logger [RottomationLogger]
      # @param auth_context [Rottomation::AuthContext] Auth context of the caller
      # @param id [int] id of the user whom is being unfollowed
      # @return [Mastodon::Entity::Account] account followed by the given user
      def self.unfollow_account(logger:, auth_context:, id:)
        resp = unfollow_account_request(logger: logger, auth_context: auth_context, id: id)
        verify_response_code(logger: logger, expected: 200, response: resp)
        Entity::Account.new(resp.parse_body_as_json)
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
        REQUIRED_PARAMS = REQUIRED_FORM_DATA_BOOL_PARAM + REQUIRED_FORM_DATA_STRING_PARAMS
        construct_methods_and_readers(bool_params: REQUIRED_FORM_DATA_BOOL_PARAM,
                                      non_bool_params: REQUIRED_FORM_DATA_STRING_PARAMS + OPTIONAL_FORM_DATA_STRING_PARAMS,
                                      required_params: REQUIRED_PARAMS)
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

      # Request body for getting statuses of a user
      class GetStatusParamBuilder < Rottomation::HttpRequestBodyBuilder
        STRING_PARAMS = %w[max_id since_id min_id limit tagged].freeze
        BOOL_PARAMS = %w[only_media exclude_replies exclude_reblogs pinned].freeze
        construct_methods_and_readers(bool_params: BOOL_PARAMS, non_bool_params: STRING_PARAMS)
      end

      # Url Param Builder for getting followers/following
      class GetFollowersParamBuilder < Rottomation::HttpRequestBodyBuilder
        PARAMS = %w[max_id since_id min_id limit].freeze
        construct_methods_and_readers(non_bool_params: PARAMS)
      end

      # Url params for optional values when following an account.
      class FollowUserParamBulder < Rottomation::HttpRequestBodyBuilder
        BOOL_PARAMS = %w[reblogs notify].freeze
        NON_BOOL_PARAMS = %w[languages].freeze
        construct_methods_and_readers(bool_params: BOOL_PARAMS, non_bool_params: NON_BOOL_PARAMS)
      end
    end
  end
end
