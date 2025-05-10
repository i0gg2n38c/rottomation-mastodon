# frozen_string_literal: true

module Mastodon
  module Service
    # comment
    class AuthenticationService < MastodonService
      SIGN_IN_URL = "#{Mastodon.INSTANCE_URL}/auth/sign_in"

      # Logins in to the configured Mastodon instance using the provided username and password.
      # @param logger [RottomationLogger] Logger instance for request logging
      # @param email [String] Email/Username to login to the instance with
      # @param password [String] Password for the user
      # @return [ottomation::AuthContext] auth_context for the provided user
      def self.sign_in(logger:, username:, password:)
        resp = get_login_form(logger: logger)
        cookies = Rottomation::HttpService.get_cookies_from_response(response: resp)

        # Process the raw HTML response to pluck out the CSRF token from the <head> section
        doc = Nokogiri::HTML(resp.body)
        csrf_element = doc.xpath('//meta[@name="csrf-token"]').first || raise('Could not find CSRF token')
        csrf = csrf_element.attr('content')

        req = Rottomation::HttpRequestBuilder.new(url: SIGN_IN_URL, method_type: :post)
                                             .with_form_body({ 'authenticity_token' => csrf,
                                                               'user[email]' => username,
                                                               'user[password]' => password,
                                                               'button' => '' })
                                             .with_session_cookies(cookies)
                                             .build
        resp = execute_request(logger: logger, request: req)
        unless resp.code == 302
          raise ArgumentError,
                "Login failed with  response code #{resp.code}\n and a response body of: #{resp.body}"
        end

        cookies = cookies.merge(Rottomation::HttpService.get_cookies_from_response(response: resp))
        Rottomation::AuthContext.new(username: username,
                                     password: password).with_session_cookies(session_cookies: cookies)
      end

      def self.get_login_form(logger:)
        request = Rottomation::HttpRequestBuilder.new(url: SIGN_IN_URL, method_type: :get)
                                                 .build
        execute_request(logger: logger, request: request)
      end

      private_class_method :get_login_form
    end
  end
end
