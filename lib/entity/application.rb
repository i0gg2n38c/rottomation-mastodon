# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Application
    class Application < Rottomation::Entity
      attr_reader :name,
                  :website,
                  :vapid_key,
                  :client_id,
                  :client_secret

      def initialize(entity)
        super()
        @name = entity[:name]
        @website = entity[:website]
        @vapid_key = entity[:vapid_key]
        @client_id = entity[:client_id]
        @client_secret = entity[:client_secret]
      end
    end
  end
end
