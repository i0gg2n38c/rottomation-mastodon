# frozen_string_literal: true

module Mastodon
  module Pages
    # TODO: Top level comment
    # Comment
    class ExplorePage < MastodonPage
      def initialize(driver)
        super(driver, '/explore/')
      end
    end
  end
end
