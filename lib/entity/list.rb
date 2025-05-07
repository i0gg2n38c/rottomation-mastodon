# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/List
    class List < Rottomation::Entity
      attr_reader :id,
                  :title

      def initialize(entity)
        super()
        @id = entity[:id]
        @title = entity[:title]
      end
    end
  end
end
