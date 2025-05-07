# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Marker
    class Marker < Rottomation::Entity
      attr_reader :home,
                  :notifications,
                  :last_read_id,
                  :updated_at,
                  :version

      def initialize(entity)
        super()
        @home = entity[:home]
        @notifications = entity[:notifications]
        @last_read_id = entity[:last_read_id]
        @updated_at = entity[:updated_at]
        @version = entity[:version]
      end
    end
  end
end
