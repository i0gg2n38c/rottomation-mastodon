# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Poll
    class Poll < Rottomation::Entity
      attr_reader :id,
                  :expires_at,
                  :expired,
                  :multiple,
                  :votes_count,
                  :voters_count,
                  :voted,
                  :own_votes,
                  :options,
                  :emojis

      def initialize(entity)
        super()
        @id = entity[:id]
        @expires_at = entity[:expires_at]
        @expired = entity[:expired]
        @multiple = entity[:multiple]
        @votes_count = entity[:votes_count]
        @voters_count = entity[:voters_count]
        @voted = entity[:voted]
        @own_votes = entity[:own_votes]
        @options = entity[:options]
        @emojis = entity[:emojis]&.map { |emoji| Emoji.new(emoji) }
      end
    end
  end
end
