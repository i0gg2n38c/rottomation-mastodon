# frozen_string_literal: true

module Mastodon
  module Pages
    # TODO: Top level comment
    # Comment
    class AboutPage < MastodonPage
      attr_reader :about_prose_xpath, :about_instance_pane

      def initialize(driver:)
        super(driver: driver, uri: '/about/')
        @about_prose_xpath = '//*[@class="about__section__body"]//*[@class="prose"]'
      end

      def loaded
        super
        begin
          about_prose
        rescue StandardError
          raise PageLoadException, 'Could not find About prose'
        end
      end

      def about_prose
        @driver.find_elements(xpath: @about_prose_xpath, element_name: 'About Prose')
               .first&.text || raise(IndexError, 'Could not find prose')
      end

      def search_instance(query:)
        Automation::Pages::Component::PaneViews::AboutInstancePane.new(driver: @driver).submit_search(query)
      end
    end
  end
end
