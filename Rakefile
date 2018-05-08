begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'QueryScope'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end


task default: :test

require 'active_record'

task :environment do
  ActiveRecord::Tasks::DatabaseTasks.database_configuration = YAML.load_file('config/database.yml')
  ActiveRecord::Tasks::DatabaseTasks.env = 'development'
  ActiveRecord::Tasks::DatabaseTasks.root = __dir__
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [ 'test/migrations' ]
  ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection :development
end

load 'active_record/railties/databases.rake'
