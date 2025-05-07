# frozen_string_literal: true

require 'rottomation'
require_relative 'requires'

# Docs
module Mastodon
  def self.INSTANCE_URL
    Rottomation::Config::Configuration.config['environment']['base_url']
  end
end
