# frozen_string_literal: true

require_relative 'spec_helper'

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
