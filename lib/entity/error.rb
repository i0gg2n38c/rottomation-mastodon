# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Error
    class Error < Rottomation::Entity
      attr_reader :error,
                  :error_description

      def initialize(entity)
        super()
        @error = entity[:error]
        @error_description = entity[:error_description]
      end
    end
  end
end
