# frozen_string_literal: true

require_relative '../spec_helper'

# TODO: Basic tests for the following. See: https://docs.joinmastodon.org/methods/accounts/
# ok    Register an account
# ok    Verify account credentials
# nd    Update account credentials
# nd    Get account
# nd    Get multiple accounts
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

  def generic_new_user_form_data
    described_class::CreateAccountFormBuilder.new
                                             .set_agreement(does_agree: true)
                                             .with_username(get_random_string(5))
                                             .with_email("#{get_random_string(6)}@#{get_random_string(6)}.test")
                                             .with_password(get_random_string(20))
                                             .with_locale('EN')
                                             .build
  end

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

    logger.log_info(log: 'Fetching account by username to get its ID')
    found_account = described_class.lookup_account(logger: logger, username: data[:username])

    logger.log_info(log: "Confirming account with user id #{found_account.id} as admin user")
    Mastodon::Service::AdminAccountsService.confirm_account(logger: logger, admin_auth_context: admin_auth_context,
                                                            id: found_account.id)

    logger.log_info(log: 'verifying credentials for the now activated user')
    validated_account = described_class.verify_credentials(logger: logger, auth_context: resp_context)
    expect(validated_account.username).to eq data[:username]
  end

  it 'can Update account credentials' do
    logger.log_info(log: 'Registering new account and getting Session Cookies')
    data = generic_new_user_form_data
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: data)

    logger.log_info(log: 'Fetching account by username to get its ID')
    found_account = described_class.lookup_account(logger: logger, username: data[:username])

    logger.log_info(log: "Confirming account with user id #{found_account.id} as admin user")
    Mastodon::Service::AdminAccountsService.confirm_account(logger: logger, admin_auth_context: admin_auth_context,
                                                            id: found_account.id)

    new_display_name = get_random_string(5)
    field_name_to_match = '1st'
    field_value_to_match = 'field'
    field_attributes = {
      "420": {
        "name": field_name_to_match,
        "value": field_value_to_match
      },
      "69": {
        "name": '2nd',
        "value": 'field'
      },
      "1312": {
        "name": '3rd',
        "value": 'field'
      },
      "-99999999999999999999999999999999": {
        "name": '4th',
        "value": 'field'
      }
    }
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
end
