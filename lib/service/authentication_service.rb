# frozen_string_literal: true

module Mastodon
  module Service
    # comment
    class AuthenticationService < MastodonService
      SIGN_IN_URL = "#{Mastodon.instance_url}/auth/sign_in"

      # Logins in to the configured Mastodon instance using the provided username and password.
      # Performs the following workflow:
      #   - Get the Login form page
      #   - Snag the CSRF token from that
      #   - Submits provided login into to the environment, with the fetched CSRF
      #   - With the returned session cookies, get the Bearer token by making a request to '/' and parses the DOM for
      #        the Bearer token
      #   - Returned the authentication context to be used in other API calls
      # @param logger [Rottomation::RottomationLogger] Logger instance for request logging
      # @param email [String] Email/Username to login to the instance with
      # @param password [String] Password for the user
      # @return [Rottomation::AuthContext] auth_context for the provided user
      def self.sign_in(logger:, username:, password:, bearer: nil)
        resp = get_login_form(logger: logger)
        cookies = resp.cookies

        # Process the raw HTML response to pluck out the CSRF token from the <head> section
        csrf = MastodonPageParsingUtils.get_csrf_from_html_response(response: resp)

        req = Rottomation::HttpRequestBuilder.new(url: SIGN_IN_URL, method_type: :post)
                                             .with_form_body({ 'authenticity_token' => csrf,
                                                               'user[email]' => username,
                                                               'user[password]' => password,
                                                               'button' => '' })
                                             .with_session_cookies(cookies)
                                             .build
        resp = execute_request(logger: logger, request: req)
        verify_response_code(logger: logger, expected: [200, 302], response: resp)

        cookies = cookies.merge(resp.cookies)

        auth_context = Rottomation::AuthContext.new(username: username, password: password)
                                               .with_session_cookies(session_cookies: cookies)
        auth_context.with_token(token: bearer) unless bearer.nil?
        return auth_context unless bearer.nil?

        # Here we just make a call to get whatever we get back from '/', providing the session cookies in the request,
        # which will give us an HTML page that we can swipe the Bearer token from
        req = Rottomation::HttpRequestBuilder.new(url: Mastodon.instance_url, method_type: :get)
                                             .with_session_cookies(cookies)
                                             .build
        resp = execute_request(logger: logger, request: req)
        verify_response_code(logger: logger, expected: [200, 302], response: resp)
        bearer = MastodonPageParsingUtils.get_bearer_token_from_html_response(resp)
        auth_context.with_token(token: "Bearer #{bearer}")
      end

      # If you already have the auth_context object, but no login cookies, utilize this method. It
      # will perform the same steps as the normal login process to get the cookies, but skip getting
      # a new Bearer token
      # @param logger [Rottomation::Logger]
      # @param auth_context [Rottomation::AuthContext]
      def self.get_session_cookies_for_auth_context(logger:, auth_context:)
        sign_in(logger: logger, username: auth_context.username, password: auth_context.password,
                bearer: auth_context.token)
      end

      def self.get_login_form(logger:)
        request = Rottomation::HttpRequestBuilder.new(url: SIGN_IN_URL, method_type: :get)
                                                 .build
        resp = execute_request(logger: logger, request: request)
        verify_response_code(logger: logger, expected: 200, response: resp)
        resp
      end

      private_class_method :get_login_form
    end
  end
end
