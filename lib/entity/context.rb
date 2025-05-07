# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Context
    class Context < Rottomation::Entity
      attr_reader :ancestors,
                  :descendants

      def initialize(entity)
        super()
        @ancestors = entity[:ancestors]&.map { |ancestor| Mastodon::Status.new(ancestor) }
        @descendants = entity[:descendants]&.map do |descendant|
          Mastodon::Status.new(descendant)
        end
      end
    end
  end
end
