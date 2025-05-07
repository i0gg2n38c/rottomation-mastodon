# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Mention
    class Mention < Rottomation::Entity
      attr_reader :id,
                  :username,
                  :acct,
                  :url

      def initialize(entity)
        super()
        @id = entity[:id]
        @username = entity[:username]
        @acct = entity[:acct]
        @url = entity[:url]
      end
    end
  end
end
