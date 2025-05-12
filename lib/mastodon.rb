# frozen_string_literal: true

require 'rottomation'

# Main module
module Mastodon
  def self.instance_url
    Rottomation::Config::Configuration.config['environment']['base_url']
  end
end

Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].sort.each do |file|
  require file unless File.expand_path(file) == File.expand_path(__FILE__)
end
