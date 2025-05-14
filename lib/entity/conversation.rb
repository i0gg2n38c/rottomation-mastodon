# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Conversation
    class Conversation < Rottomation::Entity
      attr_reader :id,
                  :accounts,
                  :unread,
                  :last_status

      def initialize(entity)
        super()
        @id = entity[:id]
        @accounts = entity[:accounts]&.map { |account| Account.new(account) }
        @unread = entity[:unread]
        @last_status = entity[:last_status].nil? ? nil : Status.new(entity[:last_status])
      end
    end
  end
end
