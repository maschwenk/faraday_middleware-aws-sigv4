if ENV['TRAVIS']
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter 'spec/'
  end
end

require 'bundler/setup'
require 'faraday_middleware'
require 'faraday_middleware/aws_sigv4'
require 'net/http'
require 'ostruct'
require 'timecop'
require 'aws-sdk-core'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Timecop.freeze(Time.utc(2015))
  end

  config.after(:each) do
    Timecop.return
  end
end
