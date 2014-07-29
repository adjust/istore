$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['DUMBO_ENV']  ||= 'development'

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
Bundler.require(:default, ENV['DUMBO_ENV'].to_sym)

def db_config
  @config ||= YAML.load_file('config/database.yml')
end

ActiveRecord::Base.establish_connection db_config[ENV['DUMBO_ENV']]
