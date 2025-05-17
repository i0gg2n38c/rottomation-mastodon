# frozen_string_literal: true

require 'concurrent'
require_relative '../spec_helper'

# TODO: Basic tests for the following. See: https://docs.joinmastodon.org/methods/accounts/
# ok    Register an account
# ok    Verify account credentials
# ok    Update account credentials
# ok    Get account
# ok    Get multiple accounts
# ok    Get account’s statuses
# ok    Get account’s followers
# ok    Get account’s following
# nd    Get account’s featured tags
# nd    Get lists containing this account
# ok    Follow account
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
  let(:user_with_followers_username) { 'dWRm8' }
  let(:user_following_other_users_username) { 'dWRm8' }

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

  # Begin Tests
  it 'can Register an account' do
    logger.log_info(log: 'Registering new account')
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: generic_new_user_form_data)
    expect(resp_context).not_to be_nil
  end

  it 'can Register an account but using auth from other user(?)' do
    form_data = generic_new_user_form_data
    new_user_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                        new_user_form_data: form_data)
    confirm_new_account(username: form_data[:username])
    new_user_context = Mastodon::Service::AuthenticationService.get_session_cookies_for_auth_context(logger: logger,
                                                                                                     auth_context: new_user_context)

    second_user_form_data = generic_new_user_form_data
    second_user_auth = described_class.register_account(logger: logger, auth_context: new_user_context,
                                                        new_user_form_data: second_user_form_data)

    confirm_new_account(username: second_user_form_data[:username])
    described_class.verify_credentials(logger: logger, auth_context: second_user_auth)
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

  it 'can fetch multiple accounts by id (but with threads!)' do
    new_users = Concurrent::Array.new
    # mutex = Mutex.new
    begin
      pool = Concurrent::FixedThreadPool.new(5)
      40.times do
        pool.post do
          new_users << create_confirmed_account(new_user_data: generic_new_user_form_data)
        end
      end

      accounts_by_id = described_class.get_accounts(logger: logger, auth_context: admin_auth_context,
                                                    ids: new_users.map(&:id))

      expect(accounts_by_id.map(&:id)).to match_array(new_users.to_a.map(&:id))
    ensure
      pool.shutdown
      pool.wait_for_termination
    end
  end

  it 'can fetch statuses for a given user id' do
    # TODO: We'll want to dynamically generate this at runtime vs relying on a constant. Update this later
    # to do so once we add the 'Post a new status' endpoint in the Status service.
    # See: https://docs.joinmastodon.org/methods/statuses/#create for docs for that.
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

  it 'can fetch followers for a given user id' do
    logger.log_info(log: 'Creating our test user')
    user_with_followers = generic_new_user_form_data
    user_with_followers_account = create_confirmed_account(new_user_data: user_with_followers)

    logger.log_info(log: 'Creating 10 new accounts, logging in with them, and following our test user')
    followers_user_data = Concurrent::Array.new
    begin
      pool = Concurrent::FixedThreadPool.new(5)

      10.times do
        pool.post do
          data = generic_new_user_form_data
          followers_user_data << data
          create_confirmed_account(new_user_data: data)
          new_user_auth_context = Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                                                   username: data[:email],
                                                                                   password: data[:password])
          described_class.follow_account(logger: logger, auth_context: new_user_auth_context,
                                         id: user_with_followers_account.id)
        end
      end
    ensure
      pool.shutdown
      pool.wait_for_termination
    end

    logger.log_info(log: 'Fetching followers for our test user')
    followers = described_class.get_accounts_followers(logger: logger, auth_context: admin_auth_context,
                                                       id: user_with_followers_account.id)
    logger.log_info(log: 'Verifying we see all 10 followers')
    expect(followers.size).to eq 10

    limit = 2
    logger.log_info(log: "Fetching followers again with limit: #{limit}")
    params = described_class::GetFollowersParamBuilder.new
                                                      .with_limit(limit)
                                                      .build

    followers = described_class.get_accounts_followers(logger: logger, auth_context: admin_auth_context,
                                                       id: user_with_followers_account.id, params: params)
    logger.log_info(log: "Verifying returned followers have only #{limit} returned accounts")
    expect(followers.size).to eq limit
  end

  it 'can fetch followed users for a given user id' do
    logger.log_info(log: 'Creating a test user')
    test_user = generic_new_user_form_data
    test_user_account = create_confirmed_account(new_user_data: test_user)
    test_user_auth_context = Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                                              username: test_user[:email],
                                                                              password: test_user[:password])

    logger.log_info(log: 'Creating 10 new users and following them with our test user')
    number_of_users = 10
    begin
      pool = Concurrent::FixedThreadPool.new(5)
      number_of_users.times do
        pool.post do
          data = generic_new_user_form_data
          data_account = create_confirmed_account(new_user_data: data)
          described_class.follow_account(logger: logger, auth_context: test_user_auth_context,
                                         id: data_account.id)
        end
      end
    ensure
      pool.shutdown
      pool.wait_for_termination
    end

    logger.log_info(log: "Fetching the followed list of our user and verifying we find #{number_of_users} accounts")
    followers = described_class.get_accounts_following(logger: logger, auth_context: admin_auth_context,
                                                       id: test_user_account.id)
    expect(followers.size).to eq number_of_users

    limit = 3
    logger.log_info(log: "Fetching the followed list with limit: #{limit}")
    params = described_class::GetFollowersParamBuilder.new
                                                      .with_limit(limit)
                                                      .build
    followers = described_class.get_accounts_following(logger: logger, auth_context: admin_auth_context,
                                                       id: test_user_account.id, params: params)
    logger.log_info(log: "Verifying we only get #{limit} users returned")
    expect(followers.size).to eq limit
  end

  it 'can follow other accounts' do
    logger.log_info(log: 'Creating two users')
    user_who_follows = generic_new_user_form_data
    user_who_is_followed = generic_new_user_form_data
    user_who_follows_account = create_confirmed_account(new_user_data: user_who_follows)
    user_who_is_followed_account = create_confirmed_account(new_user_data: user_who_is_followed)

    logger.log_info(log: 'Getting login session for the follower user')
    user_who_follows_context = Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                                                username: user_who_follows[:email],
                                                                                password: user_who_follows[:password])

    logger.log_info(log: "Following user #{user_who_is_followed[:email]} with id: #{user_who_is_followed_account.id}")
    followed_account = described_class.follow_account(logger: logger, auth_context: user_who_follows_context,
                                                      id: user_who_is_followed_account.id)

    logger.log_info(log: 'Verifying returned account id matches the expected id')
    expect(followed_account.id).to eq user_who_is_followed_account.id

    logger.log_info(log: 'Fetching the followers list')
    followers_for_followed_account = described_class.get_accounts_followers(logger: logger,
                                                                            auth_context: admin_auth_context,
                                                                            id: user_who_is_followed_account.id)
    logger.log_info(log: 'Verifying we only get 1 follower and the follower\' id matches the expected')
    expect(followers_for_followed_account.size).to be 1
    expect(followers_for_followed_account.map(&:id)[0]).to eq user_who_follows_account.id
  end

  it 'can unfollow an account' do
    logger.log_info(log: 'Creating some users')
    test_user = generic_new_user_form_data
    test_user_account = create_confirmed_account(new_user_data: test_user)
    test_user_auth_context = Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                                              username: test_user[:email],
                                                                              password: test_user[:password])

    number_of_users = 10
    users_followed = []
    begin
      pool = Concurrent::FixedThreadPool.new(5)
      number_of_users.times do
        pool.post do
          new_user = generic_new_user_form_data
          new_user_account = create_confirmed_account(new_user_data: new_user)
          users_followed << new_user_account
          logger.log_info(log: "Following user: [#{new_user_account.username}:#{new_user_account.id}]")
          described_class.follow_account(logger: logger,
                                         auth_context: test_user_auth_context,
                                         id: new_user_account.id)
        end
      end
    ensure
      pool.shutdown
      pool.wait_for_termination
    end

    number_of_users_to_unfollow = 5
    logger.log_info(log: "Unfollowing #{number_of_users_to_unfollow} users")
    users_followed.take(number_of_users_to_unfollow).each do |user|
      logger.log_info(log: "Unfollowing user: [#{user.username}:#{user.id}]")
      described_class.unfollow_account(logger: logger, auth_context: test_user_auth_context, id: user.id)
    end

    followed_users = described_class.get_accounts_following(logger: logger,
                                                            auth_context: test_user_auth_context,
                                                            id: test_user_account.id)
    expect(followed_users.size).to eq number_of_users - number_of_users_to_unfollow
  end
end
