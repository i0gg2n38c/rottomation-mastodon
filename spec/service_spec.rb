# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Mastodon::Service::TimelineService do
  let(:logger) { Rottomation::RottomationLogger.new test_name: described_class.to_s }
  let(:auth_context) { admin_auth }

  it 'can be get posts from the public timeline' do
    timeline_posts = described_class.public_timeline(logger: logger)
    expect(timeline_posts).not_to be_nil
    expect(timeline_posts.size).to eq 20
  end

  it 'can process parameters' do
    params = described_class::PublicTimelineQueryBuilder.new
                                                        .with_limit(5)
                                                        .set_local
                                                        .build
    timeline_posts = described_class.public_timeline(logger: logger, params: params)
    expect(timeline_posts).not_to be_nil
    expect(timeline_posts.size).to eq 5
  end

  it 'can filter posts by hashtag via the hashtag timeline' do
    hashtag_posts = described_class.hashtag_timeline(logger: logger, hashtag: 'cats')
    expect(hashtag_posts).not_to be_nil
    expect(hashtag_posts.size).to be > 5
    expect(hashtag_posts.all? { |status| status.content.include? 'cat' })
  end

  it 'can process parameters on the hashtag timeline' do
    limit = 5
    params = described_class::HashTagTimelineQueryBuilder.new
                                                         .with_limit(limit)
                                                         .set_local
                                                         .build
    hashtag_posts = described_class.hashtag_timeline(logger: logger, hashtag: 'cats', params: params)
    expect(hashtag_posts).not_to be_nil
    expect(hashtag_posts.size).to eq limit
    expect(hashtag_posts.all? { |status| status.content.include? 'cat' })
    expect(hashtag_posts.all? { |status| status.content.include? 'CatsOfMastodon' })
  end

  it 'can be get posts from the home timeline' do
    timeline_posts = described_class.home_timeline(logger: logger, auth_context: auth_context)
    expect(timeline_posts).not_to be_nil
    expect(timeline_posts.size).to eq 20
  end
end

RSpec.describe Mastodon::Service::AuthenticationService do
  let(:logger) { Rottomation::RottomationLogger.new test_name: described_class.to_s }

  it 'can authenticate' do
    auth_context = described_class.sign_in(logger: logger, username: admin_auth.username, password: admin_auth.password)
    expect(auth_context.username).not_to be_nil
    expect(auth_context.password).not_to be_nil
    expect(auth_context.token).not_to be_nil
    expect(auth_context.session_cookies).not_to be_nil
    expect(auth_context.session_cookies.size).to eq 2
  end
end

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

  it 'can create a new account' do
    logger.log_info(log: 'Registering new account')
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: generic_new_user_form_data)
    expect(resp_context).not_to be_nil
  end

  it 'can be used to login after creation' do
    logger.log_info(log: 'Registering new account and getting Session Cookies')
    resp_context = described_class.register_account(logger: logger, auth_context: admin_auth_context,
                                                    new_user_form_data: generic_new_user_form_data)
    expect(resp_context).not_to be_nil

    resp_context = Mastodon::Service::AuthenticationService.get_session_cookies_for_auth_context(logger: logger,
                                                                                                 auth_context: resp_context)
    expect(resp_context.session_cookies).not_to be_nil
  end

  it 'can validate bearer token' do
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
    expect(validated_account.username).to eq data['username']
  end
end
