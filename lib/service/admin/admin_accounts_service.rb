# frozen_string_literal: true

module Mastodon
  module Service
    # Service class for performing Admin actions for accounts
    class AdminAccountsService < MastodonService
      ADMIN_ACCOUNTS_BASE_URL = "#{Mastodon.instance_url}/admin/accounts"
      ADMIN_ACCOUNTS_BY_ID_URL = "#{ADMIN_ACCOUNTS_BASE_URL}/:id"
      ADMIN_ACCOUNTS_CONFIRMATION_URL = "#{ADMIN_ACCOUNTS_BY_ID_URL}/confirmation"

      ##################################################################################################################
      # SECTION: Request ###############################################################################################
      ##################################################################################################################
      def self.confirm_account_request(logger:, admin_auth_context:, id:)
        req = Mastodon::MastodonAuthedRequestBuilder.new(url: ADMIN_ACCOUNTS_CONFIRMATION_URL.gsub(':id', id),
                                                         method_type: :post)
                                                    .with_form_body({
                                                                      '_method' => 'post',
                                                                      'authenticity_token' => admin_auth_context.csrf
                                                                    })
                                                    .with_session_cookies(admin_auth_context.session_cookies)
                                                    .build

        execute_request(logger: logger, request: req)
      end

      ##################################################################################################################
      # SECTION: Processing ############################################################################################
      ##################################################################################################################
      def self.confirm_account(logger:, admin_auth_context:, id:)
        logger.log_info(log: "Fetching CSRF token for #{ADMIN_ACCOUNTS_BY_ID_URL.gsub(':id', id)}")
        csrf_resp = get_authenticity_token_for_approve_account_request(logger: logger,
                                                                       admin_auth_context: admin_auth_context,
                                                                       id: id)

        verify_response_code(logger: logger, expected: 200, response: csrf_resp)
        csrf = MastodonPageParsingUtils.get_csrf_from_html_response(response: csrf_resp)
        updated_auth_context = Rottomation::AuthContext.new(username: admin_auth_context.username,
                                                            password: admin_auth_context.password)
                                                       .with_session_cookies(session_cookies: csrf_resp.cookies)
                                                       .with_csrf(csrf: csrf)

        logger.log_info(log: "Submitting confirm account request with csrf #{csrf}")
        resp = confirm_account_request(logger: logger, admin_auth_context: updated_auth_context, id: id)
        verify_response_code(logger: logger, expected: 302, response: resp)
      end

      ##################################################################################################################
      # SECTION: Private Methods #######################################################################################
      ##################################################################################################################

      def self.get_authenticity_token_for_approve_account_request(logger:, admin_auth_context:, id:)
        req = Mastodon::MastodonAuthedRequestBuilder.new(url: ADMIN_ACCOUNTS_BY_ID_URL.gsub(':id', id),
                                                         method_type: :get)
                                                    .with_session_cookies(admin_auth_context.session_cookies)
                                                    .build
        execute_request(logger: logger, request: req)
      end

      private_class_method :get_authenticity_token_for_approve_account_request
    end
  end
end
