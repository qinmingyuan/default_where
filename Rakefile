begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'DefaultWhere'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(test: :environment) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :environment do
  ActiveRecord::Tasks::DatabaseTasks.database_configuration = YAML.load_file('test/config/database.yml')
  ActiveRecord::Tasks::DatabaseTasks.env = 'test'
  ActiveRecord::Tasks::DatabaseTasks.root = __dir__
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = ['test/migrations']
  ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection :test
end

load 'active_record/railties/databases.rake'
