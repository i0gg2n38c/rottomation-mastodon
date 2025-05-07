# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Field
    class Field < Rottomation::Entity
      attr_reader :name,
                  :value,
                  :verified_at

      def initialize(entity)
        super()
        @name = entity[:name]
        @value = entity[:value]
        @verified_at = entity[:verified_at]
      end
    end
  end
end
