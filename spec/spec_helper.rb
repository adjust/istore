require 'rubygems'
require 'dumbo/test'

ENV['DUMBO_ENV']  ||= 'test'
require File.expand_path('../../config/boot', __FILE__)

require 'dumbo/test/silence_unknown_oid'

ActiveRecord::Base.logger.level = 0 if ActiveRecord::Base.logger

Dir.glob('spec/support/**/*.rb').each { |f| require f }

RSpec.configure do |config|
  config.fail_fast                                        = false
  config.order                                            = 'random'
  config.filter_run focus: true
  config.run_all_when_everything_filtered                 = true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # wrap test in transactions
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      fail ActiveRecord::Rollback
    end
  end

  config.include(Dumbo::Test::Helper)
  config.include(Dumbo::Matchers)
end

require 'dumbo/test/regression_helper' if ENV['DUMBO_REGRESSION']