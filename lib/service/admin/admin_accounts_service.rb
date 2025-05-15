# frozen_string_literal: true

module Mastodon
  module Service
    # Service class for performing Admin actions for accounts
    class AdminAccountsService < MastodonWebService
      ADMIN_ACCOUNTS_BASE_URL = "#{Mastodon.instance_url}/admin/accounts"

      ##################################################################################################################
      # SECTION: Request ###############################################################################################
      ##################################################################################################################
      def self.confirm_account_request(logger:, admin_auth_context:, id:)
        req = MastodonAuthedRequestBuilder.new(url: "#{ADMIN_ACCOUNTS_BASE_URL}/#{id}/confirmation",
                                               method_type: :post, auth_context: admin_auth_context)
                                          .with_form_body({
                                                            '_method' => 'post',
                                                            'authenticity_token' => admin_auth_context.csrf
                                                          })
                                          .only_cookies
                                          .build

        execute_request(logger: logger, request: req)
      end

      ##################################################################################################################
      # SECTION: Processing ############################################################################################
      ##################################################################################################################
      def self.confirm_account(logger:, admin_auth_context:, id:)
        logger.log_info(log: "Fetching CSRF token for #{ADMIN_ACCOUNTS_BASE_URL}/#{id}")
        csrf_resp = get_csrf_for_approve_account_request(logger: logger,
                                                         admin_auth_context: admin_auth_context,
                                                         id: id)

        verify_response_code(logger: logger, expected: 200, response: csrf_resp)
        updated_auth_context = update_auth_context(auth_context_to_update: admin_auth_context, response: csrf_resp)

        logger.log_info(log: "Submitting confirm account request with csrf #{updated_auth_context.csrf}")
        resp = confirm_account_request(logger: logger, admin_auth_context: updated_auth_context, id: id)
        verify_response_code(logger: logger, expected: 302, response: resp)
      end

      ##################################################################################################################
      # SECTION: Private Methods #######################################################################################
      ##################################################################################################################
      def self.get_csrf_for_approve_account_request(logger:, admin_auth_context:, id:)
        req = Mastodon::MastodonAuthedRequestBuilder.new(url: "#{ADMIN_ACCOUNTS_BASE_URL}/#{id}", method_type: :get,
                                                         auth_context: admin_auth_context)
                                                    .only_cookies
                                                    .build
        execute_request(logger: logger, request: req)
      end

      private_class_method :get_csrf_for_approve_account_request
    end
  end
end
