# frozen_string_literal: true

require 'rspec'
require 'rottomation'
require_relative '../lib/mastodon'

# Tests
RSpec.describe Mastodon::Pages::AboutPage do
  let(:ldw) { Rottomation::RottomationDriverWrapper.new test_name: described_class.to_s }

  after { ldw.driver_instance&.quit }

  it 'can be created' do
    page = described_class.new driver: ldw
    page.get
    expect(page.driver.driver_instance.title).to include 'About - Mastodon'
  end
end

RSpec.describe Mastodon::Service::TimelineService do
  let(:logger) { Rottomation::RottomationLogger.new test_name: described_class.to_s }
  let(:auth_context) do
    Mastodon::Service::AuthenticationService.sign_in(logger: logger,
                                                     username: 'admin@localhost',
                                                     password: 'mastodonadmin')
  end

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
    auth_context = described_class.sign_in(logger: logger, username: 'admin@localhost', password: 'mastodonadmin')
    expect(auth_context.username).not_to be_nil
    expect(auth_context.password).not_to be_nil
    expect(auth_context.token).not_to be_nil
    expect(auth_context.session_cookies).not_to be_nil
    expect(auth_context.session_cookies.size).to eq 2
  end
end
