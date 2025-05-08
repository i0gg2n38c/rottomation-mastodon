# frozen_string_literal: true

module Mastodon
  module Service
    # comment
    class TimelineService < MastodonService
      BASE_URL = "#{Mastodon.INSTANCE_URL}/api/v1/timelines"
      PUBLIC_TIMELINE_URL = "#{BASE_URL}/public"
      HASHTAG_TIMELINE_URL = "#{BASE_URL}/tag/"

      # Fetches statuses from the public timeline
      #
      # @param logger [Logger] Logger instance for request logging
      # @param limit [Hash] queries we are providing with the request. Construct with
      # TimelineService::TimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.public_timeline(logger:, timeline_queries: nil)
        req = Rottomation::HttpRequestBuilder.new(url: PUBLIC_TIMELINE_URL, method_type: :get)
                                             .with_url_params(timeline_queries,
                                                              condition_to_include: !timeline_queries.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        resp = execute_request(logger: logger, request: req)
        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      # Fetches statuses from the public timeline filtered by the provided hashtag
      #
      # @param logger [Logger] Logger instance for request logging
      # @param hashtag [String] Hashtag to search for
      # @param limit [Integer, nil] Number of statuses to return (default: 20)
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.hashtag_timeline(logger:, hashtag:, limit: nil)
        raise ArgumentError, 'Hashtag cannot be nil' if hashtag.nil?

        req = Rottomation::HttpRequestBuilder.new(url: "#{HASHTAG_TIMELINE_URL}#{hashtag}", method_type: :get)
                                             .with_url_param('limit', limit, condition_to_include: !limit.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        resp = execute_request(logger: logger, request: req)
        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      class TimelineQueryBuilder
        STRING_QUERY_PARAMS = %w[max_id since_id min_id limit].freeze
        BOOL_QUERY_PARAMS = %w[local remote only_media].freeze

        STRING_QUERY_PARAMS.each do |param|
          attr_reader param
        end

        BOOL_QUERY_PARAMS.each do |param|
          attr_reader param
        end

        # Use meta programming to construct query building methods :D
        STRING_QUERY_PARAMS.each do |timeline_query|
          define_method("with_#{timeline_query}") do |query|
            instance_variable_set("@#{timeline_query}", query)
            self
          end
        end

        BOOL_QUERY_PARAMS.each do |timeline_query|
          define_method("set_#{timeline_query}") do
            instance_variable_set("@#{timeline_query}", true)
            self
          end
        end

        def build
          params = {}

          STRING_QUERY_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end

          BOOL_QUERY_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end
    end
  end
end
