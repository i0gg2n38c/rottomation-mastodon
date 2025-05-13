# frozen_string_literal: true

require_relative 'mastodon'

module Mastodon
  # Class to represent a Web Frontend service. The flow for most of these is:
  #   - GET the page
  #   - Fetch the CSRF token from the page (if we need it. In most cases we likely will)
  #   - Update the Session cookies with the response for the page
  #   - Perform POST/PUT/PATCH/DELETE with updated information
  #
  # Mastodon requires a different CSRF token for each Web Fromend request. Additionally, the session cookies
  # for the _mastodon_session entry also need to be updated as well.
  # the _mastodon_session cookie updates between each request and authorization will fail if we try using a
  # stale _mastodon_session cookie.
  # So the flow is generally "Get the Resource, Grab relevant security info, submit non-GET request"
  #
  # Because the flow is disctinctly different than the normal Mastodon API, I've decided to make it it's
  # own class to note that distinction
  class MastodonWebService < MastodonService
    def self.update_auth_context(auth_context_to_update:, response:, require_csrf: true)
      updated_auth_context = Rottomation::AuthContext.new(username: auth_context_to_update.username,
                                                          password: auth_context_to_update.password)
                                                     .with_session_cookies(session_cookies: response.cookies)
      return updated_auth_context unless require_csrf

      csrf = Service::MastodonPageParsingUtils.get_csrf_from_html_response(response: response)
      updated_auth_context.with_csrf(csrf: csrf)
    end
  end
end
