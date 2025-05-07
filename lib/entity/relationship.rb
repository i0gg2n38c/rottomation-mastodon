# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Relationship
    class Relationship < Rottomation::Entity
      attr_reader :id,
                  :following,
                  :requested,
                  :endorsed,
                  :followed_by,
                  :muting,
                  :muting_notifications,
                  :showing_reblogs,
                  :blocking,
                  :domain_blocking,
                  :blocked_by

      def initialize(entity)
        super()
        @id = entity[:id]
        @following = entity[:following]
        @requested = entity[:requested]
        @endorsed = entity[:endorsed]
        @followed_by = entity[:followed_by]
        @muting = entity[:muting]
        @muting_notifications = entity[:muting_notifications]
        @showing_reblogs = entity[:showing_reblogs]
        @blocking = entity[:blocking]
        @domain_blocking = entity[:domain_blocking]
        @blocked_by = entity[:blocked_by]
      end
    end
  end
end
