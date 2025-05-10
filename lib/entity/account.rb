# frozen_string_literal: true

require_relative '../../lib/mastodon'
require_relative 'emoji'
require_relative 'field'
require_relative 'source'

module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Account
    class Account < Rottomation::Entity
      attr_reader :id,
                  :username,
                  :acct,
                  :url,
                  :display_name,
                  :note,
                  :avatar,
                  :avatar_static,
                  :header,
                  :header_static,
                  :locked,
                  :emojis,
                  :discoverable,
                  :created_at,
                  :statuses_count,
                  :followers_count,
                  :following_count,
                  :moved,
                  :fields,
                  :bot,
                  :source

      def initialize(entity) # rubocop:disable Metrics/AbcSize
        super()
        @id = entity[:id]
        @username = entity[:username]
        @acct = entity[:acct]
        @url = entity[:url]
        @display_name = entity[:display_name]
        @note = entity[:note]
        @avatar = entity[:avatar]
        @avatar_static = entity[:avatar_static]
        @header = entity[:header]
        @header_static = entity[:header_static]
        @locked  = entity[:locked]
        @emojis  = entity[:emojis]&.map { |emoji| Emoji.new(emoji) }
        @discoverable = entity[:discoverable]
        @created_at = entity[:created_at]
        @statuses_count = entity[:statuses_count]
        @followers_count = entity[:followers_count]
        @following_count = entity[:following_count]
        @moved = entity[:moved].nil? ? nil : Account.new(entity[:moved])
        @fields = entity[:fields]&.map { |field| Field.new(field) }
        @bot = entity[:bot]
        @source = entity[:source].nil? ? nil : Source.new(entity[:source])
      end
    end
  end
end
