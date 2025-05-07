# frozen_string_literal: true

require_relative 'account'
require_relative 'card'
require_relative '../mastodon'
module Mastodon
  module Entity
    # see: https://mastodon.gitbook.io/mastodon/entities/Status
    class Status < Rottomation::Entity
      attr_reader :id,
                  :uri,
                  :created_at,
                  :account,
                  :content,
                  :text,
                  :visibility,
                  :sensitive,
                  :spoiler_text,
                  :media_attachments,
                  :application,
                  :mentions,
                  :tags,
                  :emojis,
                  :reblogs_count,
                  :favourites_count,
                  :replies_count,
                  :url,
                  :in_reply_to_id,
                  :in_reply_to_account_id,
                  :reblog,
                  :poll,
                  :card,
                  :language,
                  :favourited,
                  :reblogged,
                  :muted,
                  :bookmarked,
                  :pinned

      class Visibility
        CONTEXT_TYPES = %i[public unlisted private direct].freeze

        def self.from_s(str)
          str = str.to_s.downcase
          sym = str.to_sym
          raise ArgumentError, "Invalid Context Type: #{str}" unless CONTEXT_TYPES.include?(sym)

          sym
        end
      end

      def initialize(entity)
        super()
        @id = entity[:id]
        @uri = entity[:uri]
        @created_at = entity[:created_at]
        @account = Account.new(entity[:account])
        @content = entity[:content]
        @text = entity[:text]
        @visibility = entity[:visibility].nil? ? nil : Visibility.from_s(entity[:visibility])
        @sensitive = entity[:sensitive]
        @spoiler_text = entity[:spoiler_text]
        @media_attachments = entity[:media_attachments]&.map do |attachment|
          Attachment.new(attachment)
        end
        @application = entity[:application].nil? ? nil : Application.new(entity[:application])
        @mentions = entity[:mentions]&.map { |mention| Mention.new(mention) }
        @tags = entity[:tags]&.map { |tag| Tag.new(tag) }
        @emojis = entity[:emojis]&.map { |emoji| Emoji.new(emoji) }
        @reblogs_count = entity[:reblogs_count]
        @favourites_count = entity[:favourites_count]
        @replies_count = entity[:replies_count]
        @url = entity[:url]
        @in_reply_to_id = entity[:in_reply_to_id]
        @in_reply_to_account_id = entity[:in_reply_to_account_id]
        @reblog = entity[:reblog].nil? ? nil : Status.new(entity[:reblog])
        @poll = entity[:poll].nil? ? nil : Poll.new(entity[:poll])
        @card = entity[:card].nil? ? nil : Card.new(entity[:card])
        @language = entity[:language]
        @favourited = entity[:favourited]
        @reblogged = entity[:reblogged]
        @muted = entity[:muted]
        @bookmarked = entity[:bookmarked]
        @pinned = entity[:pinned]
      end
    end
  end
end
