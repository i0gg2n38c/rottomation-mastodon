# frozen_string_literal: true

# requires.rb
Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].sort.each do |file|
  require file unless File.expand_path(file) == File.expand_path(__FILE__)
end
