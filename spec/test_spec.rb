# frozen_string_literal: true

require 'rspec'
require 'rottomation'
require_relative '../lib/mastodon'

# Tests
RSpec.describe Mastodon::Pages::AboutPage do
  let(:ldw) { Rottomation::IO::RottomationDriverWrapper.new test_name: described_class.to_s }

  after { ldw.driver_instance&.quit }

  it 'can be created' do
    page = described_class.new driver: ldw
    page.get
    expect(page.driver.driver_instance.title).to include 'About - Mastodon'
  end
end

RSpec.describe Mastodon::Service::TimelineService do
  let(:logger) { Rottomation::IO::RottomationLogger.new test_name: described_class.to_s }

  it 'can be get posts from the timeline' do
    timeline_posts = described_class.public_timeline(logger: logger)
    expect(timeline_posts).not_to be_nil
    expect(timeline_posts.size).to eq 20
  end

  it 'can limit the number of posts returned' do
    timeline_posts = described_class.public_timeline(logger: logger, limit: 5)
    expect(timeline_posts).not_to be_nil
    expect(timeline_posts.size).to eq 5
  end

  it 'can filter posts by hashtag' do
    hashtag_posts = described_class.hashtag_timeline(logger: logger, hashtag: 'cats')
    expect(hashtag_posts).not_to be_nil
    expect(hashtag_posts.size).to eq 20
    expect(hashtag_posts.all? { |status| status.content.include? 'cat' })
  end
end
