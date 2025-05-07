# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Instance
    class Instance < Rottomation::Entity
      attr_reader :uri,
                  :title,
                  :description,
                  :short_description,
                  :email,
                  :version,
                  :languages,
                  :registrations,
                  :approval_required,
                  :urls,
                  :stats,
                  :thumbnail,
                  :contact_account

      def initialize(entity)
        super()
        @uri = entity[:uri]
        @title = entity[:title]
        @description = entity[:description]
        @short_description = entity[:short_description]
        @email = entity[:email]
        @version = entity[:version]
        @languages = entity[:languages]
        @registrations = entity[:registrations]
        @approval_required = entity[:approval_required]
        @urls = entity[:urls]
        @stats = entity[:stats]
        @thumbnail = entity[:thumbnail]
        @contact_account = entity[:contact_account]
      end
    end
  end
end
