# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see: https://mastodon.gitbook.io/mastodon/entities/Card
    class Card < Rottomation::Entity
      attr_reader :url,
                  :title,
                  :description,
                  :type,
                  :author_name,
                  :author_url,
                  :provider_name,
                  :provider_url,
                  :html,
                  :width,
                  :height,
                  :image,
                  :embed_url

      def initialize(entity)
        super()
        @url = entity[:url]
        @title = entity[:title]
        @description = entity[:description]
        @type = entity[:type]
        @author_name = entity[:author_name]
        @author_url = entity[:author_url]
        @provider_name = entity[:provider_name]
        @provider_url = entity[:provider_url]
        @html = entity[:html]
        @width = entity[:width]
        @height = entity[:height]
        @image = entity[:image]
        @embed_url = entity[:embed_url]
      end
    end
  end
end
