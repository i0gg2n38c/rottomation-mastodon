# frozen_string_literal: true

require_relative 'account'
require_relative '../mastodon'
module Mastodon
  module Entity
    # see: https://mastodon.gitbook.io/mastodon/entities/Token
    class Token < Rottomation::Entity
      attr_reader :access_token,
                  :token_type,
                  :scope,
                  :created_at

      def initialize(entity)
        super()
        @access_token = entity[:access_token]
        @token_type = entity[:token_type]
        @scope = entity[:scope]
        @created_at = entity[:created_at]
      end
    end
  end
end
