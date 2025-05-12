# frozen_string_literal: true

module Mastodon
  module Service
    # Utility class for accessing shared page parsing utilities
    class MastodonPageParsingUtils
      def self.get_csrf_from_html_response(response:)
        # Process the raw HTML response to pluck out the CSRF token from the <head> section
        doc = Nokogiri::HTML(response.body)
        csrf_element = doc.xpath('//meta[@name="csrf-token"]').first || raise('Could not find CSRF token')
        csrf_element.attr('content')
      end

      def self.get_bearer_token_from_html_response(response)
        # Process the raw HTML response to pluck out the CSRF token from the <head> section
        doc = Nokogiri::HTML(response.body)
        csrf_element = doc.xpath('//script[@id="initial-state"]').first ||
                       raise('Could not find initial-state element for Bearer token')
        JSON.parse(csrf_element.inner_html, symbolize_names: true)[:meta][:access_token]
      end
    end
  end
end
