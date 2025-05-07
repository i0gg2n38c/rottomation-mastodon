# frozen_string_literal: true

require_relative 'mastodon'

module Mastodon
  module Pages
    # TODO: Top level comment
    # Comment
    class MastodonPage < Rottomation::Pages::Page
      def initialize(driver:, uri: '', query: [])
        super(driver: driver, base_url: Mastodon.INSTANCE_URL, uri: uri, query: [])
      end
    end
  end
end
