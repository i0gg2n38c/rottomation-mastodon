# frozen_string_literal: true

require_relative '../spec_helper'

# TODO: Basic tests for the following. See: https://docs.joinmastodon.org/methods/accounts/
# ok    Register an account
# ok    Verify account credentials
# ok    Update account credentials
# ok    Get account
# ok    Get multiple accounts
# nd    Get account’s statuses
# nd    Get account’s followers
# nd    Get account’s following
# nd    Get account’s featured tags
# nd    Get lists containing this account
# nd    Follow account
# nd    Unfollow account
# nd    Remove account from followers
# nd    Block account
# nd    Unblock account
# nd    Mute account
# nd    Unmute account
# nd    Feature account on your profile
# nd    Unfeature account from profile
# nd    Set private note on profile
# nd    Check relationships to other accounts
# nd    Find familiar followers
# nd    Search for matching accounts
# nd    Lookup account ID from Webfinger address

RSpec.describe Mastodon::Service::AccountService do
  let(:logger) { Rottomation::RottomationLogger.new test_name: described_class.to_s }
  let(:admin_auth_context) { admin_auth }
  let(:new_display_name) { get_random_string(5) }
  let(:field_name_to_match) { 'left' }
  let(:field_value_to_match) { 'field' }
  let(:attribution_domains) { ['www.google.com', 'www.meta.com'] }
  let(:field_attributes) do
    {
      "1": {
        "name": field_name_to_match,
        "value": field_value_to_match
      },
      "2": {
        "name": 'Hugh',
        "value": 'Jazz'
      },
      "3": {
        "name": 'Seymore',
        "value": 'Cox'
      },
      "4": {
        "name": 'I. C.',
        "value": 'Wiener'
      }
    }
  end
  let(:user_with_posts_username) { 'nA6Xv' }

  def generic_new_user_form_data
    described_class::CreateAccountFormBuilder.new
                                             .set_agreement(does_agree: true)
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

  # Begin Tests
  it 'can Register an account' do
    logger.log_info(log: 'Registering new account')
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: generic_new_user_form_data)
    expect(resp_context).not_to be_nil
  end

  it 'can Verify account credentials' do
    logger.log_info(log: 'Registering new account and getting Session Cookies')
    data = generic_new_user_form_data
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: data)
    confirm_new_account(username: data[:username])

    logger.log_info(log: 'verifying credentials for the now activated user')
    validated_account = described_class.verify_credentials(logger: logger, auth_context: resp_context)
    expect(validated_account.username).to eq data[:username]
  end

  it 'can Update account credentials' do
    logger.log_info(log: 'Registering new account and getting Session Cookies')
    data = generic_new_user_form_data
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: data)
    confirm_new_account(username: data[:username])

    # TODO: with_attribution_domains won't work until Mastodon 4.4.0. At the time of writing we are on version
    # 4.3.8
    body = described_class::UpdateCredentialsBuilder.new
                                                    .with_display_name(new_display_name)
                                                    # .with_attribution_domains(['www.google.com', 'www.meta.com'])
                                                    .with_fields_attributes(field_attributes)
                                                    .build

    logger.log_info(log: 'verifying credentials for the now activated user')
    updated_account = described_class.update_credentials(logger: logger, auth_context: resp_context,
                                                         updated_credentials: body)
    expect(updated_account.display_name).to eq new_display_name
    expect(updated_account.fields.first.name).to eq field_name_to_match
    expect(updated_account.fields.first.value).to eq field_value_to_match
  end

  it 'can fetch a single account' do
    created_account = create_confirmed_account(new_user_data: generic_new_user_form_data)

    account_by_id = described_class.get_account(logger: logger, auth_context: admin_auth_context,
                                                id: created_account.id)

    expect(account_by_id.username).to eq created_account.username
    expect(account_by_id.id).to eq created_account.id
  end

  it 'can fetch multiple accounts by id' do
    new_users = []
    5.times do
      new_users << create_confirmed_account(new_user_data: generic_new_user_form_data)
    end
    accounts_by_id = described_class.get_accounts(logger: logger, auth_context: admin_auth_context,
                                                  ids: new_users.map(&:id))

    expect(accounts_by_id.map(&:id)).to match_array(new_users.map(&:id))
  end

  it 'can fetch statuses for a given user id' do
    user_with_posts = described_class.lookup_account(logger: logger, username: user_with_posts_username)
    statuses = described_class.get_accounts_statuses(logger: logger, auth_context: admin_auth_context,
                                                     id: user_with_posts.id)
    expect(statuses).not_to be_empty

    params = described_class::GetStatusParamBuilder.new
                                                   .with_since_id(statuses[-3].id)
                                                   .build

    since_statuses = described_class.get_accounts_statuses(logger: logger, auth_context: admin_auth_context,
                                                           id: user_with_posts.id, params: params)
    expect(since_statuses.size).to eq statuses.size - 3
  end
end
