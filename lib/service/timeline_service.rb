# frozen_string_literal: true

module Mastodon
  module Service
    # comment
    class TimelineService < MastodonService
      BASE_URL = "#{Mastodon.instance_url}/api/v1/timelines"
      PUBLIC_TIMELINE_URL = "#{BASE_URL}/public"
      HOME_TIMELINE_URL = "#{BASE_URL}/home"
      HASHTAG_TIMELINE_URL = "#{BASE_URL}/tag/"

      ##################################################################################################################
      # SECTION: Request ###############################################################################################
      ##################################################################################################################

      # Fires request to fetch statuses from the public timeline
      #
      # @param logger [RottomationLogger] Logger instance for request logging
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::TimelineQueryBuilder#build
      # @return [Rottomation::HttpResponse] Raw response object from this endpoint
      def self.public_timeline_request(logger:, params: nil)
        req = Rottomation::HttpRequestBuilder.new(url: PUBLIC_TIMELINE_URL, method_type: :get)
                                             .with_url_params(params, condition_to_include: !params.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        execute_request(logger: logger, request: req)
      end

      # Fires request to fetch statuses from the public timeline filtered by the provided hashtag
      #
      # @param logger [RottomationLogger] Logger instance for request logging2
      # @param hashtag [String] Hashtag to search for
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::HashTagTimelineQueryBuilder#build
      # @return [Rottomation::HttpResponse] Raw response object from this endpoint
      def self.hashtag_timeline_request(logger:, hashtag:, params: nil)
        raise ArgumentError, 'Hashtag cannot be nil' if hashtag.nil?

        req = Rottomation::HttpRequestBuilder.new(url: "#{HASHTAG_TIMELINE_URL}#{hashtag}", method_type: :get)
                                             .with_url_params(params, condition_to_include: !params.nil?)
                                             .with_header('accept', 'application/json')
                                             .build
        execute_request(logger: logger, request: req)
      end

      # Fires request to fetch statuses from the home timeline using the provided authorization context
      #
      # @param logger [RottomationLogger] Logger instance for request logging2
      # @param auth_context [Rottomation::AuthContext] Hashtag to search for
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::HashTagTimelineQueryBuilder#build
      # @return [Rottomation::HttpResponse] Raw response object from this endpoint
      def self.home_timeline_request(logger:, auth_context:, params: nil)
        req = Mastodon::MastodonAuthedRequestBuilder.new(url: HOME_TIMELINE_URL, method_type: :get)
                                                    .with_auth(auth_context: auth_context)
                                                    .with_url_params(params, condition_to_include: !params.nil?)
                                                    .build
        execute_request(logger: logger, request: req)
      end

      ##################################################################################################################
      # SECTION: Processing ############################################################################################
      ##################################################################################################################

      # Fetches statuses from the public timeline
      #
      # @param logger [RottomationLogger] Logger instance for request logging
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::TimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.public_timeline(logger:, params: nil)
        resp = public_timeline_request(logger: logger, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)

        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      # Fetches statuses from the public timeline filtered by the provided hashtag
      #
      # @param logger [RottomationLogger] Logger instance for request logging2
      # @param hashtag [String] Hashtag to search for
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::HashTagTimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.hashtag_timeline(logger:, hashtag:, params: nil)
        resp = hashtag_timeline_request(logger: logger, hashtag: hashtag, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)

        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      # Fetches statuses from the home timeline using the provided authorization context
      #
      # @param logger [RottomationLogger] Logger instance for request logging2
      # @param auth_context [Rottomation::AuthContext] Hashtag to search for
      # @param params [Hash, nil] url params we are providing with the request. Construct with
      # TimelineService::HashTagTimelineQueryBuilder#build
      # @return [Array<Mastodon::Entity::Status>] Collection of status objects
      def self.home_timeline(logger:, auth_context:, params: nil)
        resp = home_timeline_request(logger: logger, auth_context: auth_context, params: params)
        verify_response_code(logger: logger, expected: 200, response: resp)

        JSON.parse(resp.body, symbolize_names: true).map { |entry| Mastodon::Entity::Status.new(entry) }
      end

      ##################################################################################################################
      # SECTION: Builders ##############################################################################################
      ##################################################################################################################

      # Base Query Builder class for the Timeline API endpoints.
      class TimelineQueryBuilder
        HOME_QUERY_PARAMS = %w[max_id since_id min_id limit].freeze

        HOME_QUERY_PARAMS.each do |param|
          attr_reader param

          define_method("with_#{param}") do |query|
            instance_variable_set("@#{param}", query)
            self
          end
        end

        def build
          params = {}

          HOME_QUERY_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end

      # Builder class for constructing the URL parameters for the public_timeline endpoint
      class PublicTimelineQueryBuilder < TimelineQueryBuilder
        PUBLIC_QUERY_PARAMS = %w[local remote only_media].freeze

        PUBLIC_QUERY_PARAMS.each do |param|
          attr_reader param

          define_method("set_#{param}") do
            instance_variable_set("@#{param}", true)
            self
          end
        end

        def build
          params = super

          PUBLIC_QUERY_PARAMS.each do |param|
            val = instance_variable_get("@#{param}")
            params[param.to_sym] = val unless val.nil?
          end
          params
        end
      end

      # Builder class for constructing the URL parameters for the hashtag_timeline endpoint
      class HashTagTimelineQueryBuilder < PublicTimelineQueryBuilder
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
