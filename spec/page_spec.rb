# frozen_string_literal: true

require 'concurrent'
require_relative 'spec_helper'

RSpec.describe Mastodon::Pages::AboutPage do
  it 'can use the driver manager to open the About page 10 times with < 10 total grid nodes' do
    test_procedure = proc do |ldw:|
      page = described_class.new driver: ldw
      page.get
      expect(page.driver.driver_instance.title).to include 'About - Mastodon'
    end

    pool = Concurrent::FixedThreadPool.new(10)
    10.times do
      pool.post do
        Rottomation::DriverManager.execute_test(test_procedure: test_procedure,
                                                test_name: 'Testing the driver manager')
      end
    end
    pool.shutdown
    pool.wait_for_termination
  end
end
