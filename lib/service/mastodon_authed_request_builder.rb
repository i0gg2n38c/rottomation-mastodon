# frozen_string_literal: true

module Mastodon
  # Base class for building Authenticated Mastodon API requests
  class MastodonAuthedRequestBuilder < Rottomation::HttpRequestBuilder
    def with_auth(auth_context:)
      with_session_cookies(auth_context.session_cookies)
      with_header('Authorization', auth_context.token)
    end
  end
end
