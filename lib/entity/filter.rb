# frozen_string_literal: true

require_relative '../mastodon'
module Mastodon
  module Entity
    # see https://mastodon.gitbook.io/mastodon/entities/Filter
    class Filter < Rottomation::Entity
      attr_reader :id,
                  :phrase,
                  :context,
                  :expires_at,
                  :irreversible,
                  :whole_word

      class ContextType
        CONTEXT_TYPES = %i[home notifications public thread].freeze

        def self.from_s(str)
          str = str.to_s.downcase
          sym = str.to_sym
          raise ArgumentError, "Invalid Context Type: #{str}" unless CONTEXT_TYPES.include?(sym)

          sym
        end
      end

      def initialize(entity)
        super()
        @id = entity[:id]
        @phrase = entity[:phrase]
        @context = entity[:context].nil? ? nil : ContextType.from_s(entity[:context])
        @expires_at = entity[:expires_at]
        @irreversible = entity[:irreversible]
        @whole_word = entity[:whole_word]
      end
    end
  end
end
