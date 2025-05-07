# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/PushSubscription
    class PushSubscription < Rottomation::Entity
      attr_reader :id,
                  :endpoint,
                  :server_key,
                  :alerts

      def initialize(entity)
        super()
        @id = entity[:id]
        @endpoint = entity[:endpoint]
        @server_key = entity[:server_key]
        @alerts = entity[:alerts]
      end
    end
  end
end
