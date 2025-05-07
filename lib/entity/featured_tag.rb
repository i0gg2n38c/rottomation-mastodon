# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/FeaturedTag
    class FeaturedTag < Rottomation::Entity
      attr_reader :id,
                  :name,
                  :statuses_count,
                  :last_status_at

      def initialize(entity)
        super()
        @id = entity[:id]
        @name = entity[:name]
        @statuses_count = entity[:statuses_count]
        @last_status_at = entity[:last_status_at]
      end
    end
  end
end
