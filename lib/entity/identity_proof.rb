# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/IdentityProof
    class IdentityProof < Rottomation::Entity
      attr_reader :provider,
                  :provider_username,
                  :profile_url,
                  :proof_url,
                  :updated_at

      def initialize(entity)
        super()
        @provider = entity[:provider]
        @provider_username = entity[:provider_username]
        @profile_url = entity[:profile_url]
        @proof_url = entity[:proof_url]
        @updated_at = entity[:updated_at]
      end
    end
  end
end
