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
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::TimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.public_timeline(logger:, params: nil)
        req = Rottomation::HttpRequestBuilder.new(url: PUBLIC_TIMELINE_URL, method_type: :get)
                                             .with_url_params(params, condition_to_include: !params.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        resp = execute_request(logger: logger, request: req)
        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      # Fetches statuses from the public timeline filtered by the provided hashtag
      #
      # @param logger [Logger] Logger instance for request logging
      # @param hashtag [String] Hashtag to search for
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::HashTagTimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.hashtag_timeline(logger:, hashtag:, params: nil)
        raise ArgumentError, 'Hashtag cannot be nil' if hashtag.nil?

        req = Rottomation::HttpRequestBuilder.new(url: "#{HASHTAG_TIMELINE_URL}#{hashtag}", method_type: :get)
                                             .with_url_params(params, condition_to_include: !params.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        resp = execute_request(logger: logger, request: req)
        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      # Builder class for constructing the URL parameters for the public_timeline endpoint
      class TimelineQueryBuilder
        STRING_QUERY_PARAMS = %w[max_id since_id min_id limit].freeze
        BOOL_QUERY_PARAMS = %w[local remote only_media].freeze
        QUERY_PARAMS = STRING_QUERY_PARAMS + BOOL_QUERY_PARAMS

        # Use meta programming to make readers and builder methods for the param types :D
        STRING_QUERY_PARAMS.each do |param|
          attr_reader param

          define_method("with_#{param}") do |query|
            instance_variable_set("@#{param}", query)
            self
          end
        end

        BOOL_QUERY_PARAMS.each do |param|
          attr_reader param

          define_method("set_#{param}") do
            instance_variable_set("@#{param}", true)
            self
          end
        end

        def build
          params = {}

          QUERY_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end

      # Builder class for constructing the URL parameters for the hashtag_timeline endpoint
      class HashTagTimelineQueryBuilder < TimelineQueryBuilder
        HASHTAG_QUERIES = %w[any all none].freeze

        HASHTAG_QUERIES.each do |param|
          attr_reader param

          define_method("with_#{param}") do |query|
            instance_variable_set("@#{param}", query)
            self
          end
        end

        def build
          params = super

          HASHTAG_QUERIES.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end
    end
  end
end
