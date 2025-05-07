# frozen_string_literal: true

require_relative 'account'
require_relative '../mastodon'
module Mastodon
  module Entity
    # see: https://mastodon.gitbook.io/mastodon/entities/Tag
    class Tag < Rottomation::Entity
      attr_reader :name,
                  :url,
                  :history

      def initialize(entity)
        super()
        @name = entity[:name]
        @url = entity[:url]
        @history = entity[:history]
      end
    end
  end
end
