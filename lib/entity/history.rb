# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/History
    class History < Rottomation::Entity
      attr_reader :day,
                  :uses,
                  :accounts

      def initialize(entity)
        super()
        @day = entity[:day]
        @uses = entity[:uses]
        @accounts = entity[:accounts]
      end
    end
  end
end
