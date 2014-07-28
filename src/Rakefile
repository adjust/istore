require 'rake'
require 'rspec/core/rake_task'
require 'dumbo/rake_task'
require 'dumbo/db_task'
require 'dumbo'

load File.expand_path('../config/boot.rb', __FILE__)

Dumbo::RakeTask.new(:dumbo)
Dumbo::DbTask.new(:db)
RSpec::Core::RakeTask.new(:spec)

Dir.glob('lib/tasks/**/*.rake').each { |taskfile| load taskfile }

task default: ['dumbo:all', 'db:test:prepare', :spec]
