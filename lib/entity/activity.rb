# frozen_string_literal: true

require_relative '../mastodon'

module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Activity
    class Activity < Rottomation::Entity
      attr_reader :week,
                  :statuses,
                  :logins,
                  :registrations

      def initialize(entity)
        super()
        @week = entity[:week]
        @statuses = entity[:statuses]
        @logins = entity[:logins]
        @registrations = entity[:registrations]
      end
    end
  end
end
