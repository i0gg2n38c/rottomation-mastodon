# frozen_string_literal: true

require 'requires'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Shared method to get a random String of a particular length
# Exists just to have a shorter string than 'SecureRandom.alphanumeric'
# @param len [int] length of the string you want returned
def get_random_string(len)
  SecureRandom.alphanumeric(len)
end

@admin_auth = nil

# Gets an AuthContext instance for the Instance Admin account. Tries to reduce the number of login
# attempts by using a variable and only logging in if it's nil
def admin_auth
  @admin_auth ||= Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                                   username: 'admin@localhost',
                                                                   password: 'mastodonadmin')
end
