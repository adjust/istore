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

  def types
    [:bigistore, :istore]
  end

  def val_type
    {istore: 'int', bigistore: 'bigint'}
  end

  def values
    {
      istore: {
        low: -2147483647,
        neg: -5,
        pos: 5,
        high: 2147483647
      },
      bigistore: {
        low: -9223372036854775807,
        neg: -5,
        pos: 5,
        high: 9223372036854775806
      }
    }
  end

  def sample
    {
      istore: "'-2147483647 => 10, -10 => -2147483647, 0 => 5, 10 => 2147483647, 2147483647 => 10'",
      bigistore: "'-2147483647 => 10, -10 => -9223372036854775807, 0 => 5, 10 => 9223372036854775806, 2147483647 => 10'",
    }
  end

  def sample_out
    {
      istore: %{"-2147483647"=>"10", "-10"=>"-2147483647", "0"=>"5", "10"=>"2147483647", "2147483647"=>"10"},
      bigistore: %{"-2147483647"=>"10", "-10"=>"-9223372036854775807", "0"=>"5", "10"=>"9223372036854775806", "2147483647"=>"10"},
    }
  end
end

require 'dumbo/test/regression_helper' if ENV['DUMBO_REGRESSION']