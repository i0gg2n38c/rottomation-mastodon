# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Notification
    class Notification < Rottomation::Entity
      attr_reader :id,
                  :type,
                  :created_at,
                  :account,
                  :status

      def initialize(entity)
        super()
        @id = entity[:id]
        @type = entity[:username]
        @created_at = entity[:created_at]
        @account = entity[:account].nil? ? nil : Mastodon::Account.new(entity[:account])
        @status = entity[:status].nil? ? nil : Mastodon::Status.new(entity[:status])
      end
    end
  end
end
