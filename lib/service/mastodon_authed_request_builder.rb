# frozen_string_literal: true

module Mastodon
  # Base class for building Authenticated Mastodon API requests
  class MastodonAuthedRequestBuilder < Rottomation::HttpRequestBuilder
    def initialize(url:, method_type:, auth_context:)
      super(url: url, method_type: method_type)
      with_session_cookies(auth_context.session_cookies) unless auth_context.session_cookies.nil?
      with_header('Authorization', auth_context.token)
    end

    def only_cookies
      @headers.delete('Authorization')
      self
    end
  end
end
