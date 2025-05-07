# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Attachment
    class Attachment < Rottomation::Entity
      attr_reader :id,
                  :type,
                  :website,
                  :url,
                  :preview_url,
                  :remote_url,
                  :text_url,
                  :meta,
                  :description,
                  :blurhash

      def initialize(entity)
        super()
        @id = entity[:id]
        @type = entity[:type]
        @url = entity[:url]
        @preview_url = entity[:preview_url]
        @remote_url = entity[:remote_url]
        @text_url = entity[:text_url]
        @meta = entity[:meta]
        @description = entity[:description]
        @blurhash = entity[:blurhash]
      end
    end
  end
end
