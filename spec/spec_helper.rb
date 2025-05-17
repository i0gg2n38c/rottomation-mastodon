# frozen_string_literal: true

require 'rspec'
require 'rottomation'
require 'securerandom'
require_relative '../lib/mastodon'

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

def generic_new_user_form_data
  described_class::CreateAccountFormBuilder.new
                                           .set_agreement(true)
                                           .with_username(get_random_string(5))
                                           .with_email("#{get_random_string(6)}@#{get_random_string(6)}.test")
                                           .with_password(get_random_string(20))
                                           .with_locale('EN')
                                           .build
end

def confirm_new_account(username:)
  logger.log_info(log: 'Fetching account by username to get its ID')
  found_account = described_class.lookup_account(logger: logger, username: username)

  logger.log_info(log: "Confirming account with user id #{found_account.id} as admin user")
  Mastodon::Service::AdminAccountsService.confirm_account(logger: logger, admin_auth_context: admin_auth_context,
                                                          id: found_account.id)
end

def create_confirmed_account(new_user_data:)
  described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                   new_user_form_data: new_user_data)
  logger.log_info(log: 'Fetching account by username to get its ID')
  created_account = described_class.lookup_account(logger: logger, username: new_user_data[:username])

  logger.log_info(log: "Confirming account with user id #{created_account.id} as admin user")
  Mastodon::Service::AdminAccountsService.confirm_account(logger: logger, admin_auth_context: admin_auth_context,
                                                          id: created_account.id)
  created_account
end
