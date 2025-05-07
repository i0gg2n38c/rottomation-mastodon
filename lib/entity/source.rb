# frozen_string_literal: true

require_relative '../mastodon'
require_relative 'account'

module Mastodon
  module Entity
    # see: https://mastodon.gitbook.io/mastodon/entities/Status
    class Source < Rottomation::Entity
      attr_reader :note,
                  :fields,
                  :privacy,
                  :sensitive,
                  :language,
                  :follow_requests_count

      def initialize(entity)
        super()
        @note = entity[:note]
        @fields = entity[:fields]&.map { |field| Mastodon::Field.new(field) }
        @privacy = entity[:privacy]
        @sensitive = entity[:sensitive]
        @language = entity[:language]
        @follow_requests_count = entity[:follow_requests_count]
      end
    end
  end
end
