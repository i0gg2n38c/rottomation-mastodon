# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Results
    class Results < Rottomation::Entity
      attr_reader :accounts,
                  :statuses,
                  :hashtags

      def initialize(entity)
        super()
        @accounts = entity[:accounts]&.map { |account| Account.new(account) }
        @statuses = entity[:statuses]&.map { |status| Status.new(status) }
        @hashtags = entity[:hashtags]&.map { |hashtag| Tag.new(hashtag) }
      end
    end
  end
end
