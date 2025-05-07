# frozen_string_literal: true

module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Emoji
    class Emoji < Rottomation::Entity
      attr_reader :shortcode,
                  :url,
                  :static_url,
                  :visible_in_picker,
                  :category

      def initialize(entity)
        super()
        @shortcode = entity[:shortcode]
        @url = entity[:url]
        @static_url = entity[:static_url]
        @visible_in_picker = entity[:visible_in_picker]
        @category = entity[:category]
      end
    end
  end
end
