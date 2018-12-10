require 'active_record'
require 'minitest/autorun'
require 'factory_bot'

ActiveRecord::Schema.verbose = false
ActiveRecord::Tasks::DatabaseTasks.database_configuration = YAML.load_file('test/config/database.yml')
ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
ActiveRecord::Base.establish_connection :test

if defined?(FactoryBot)
  FactoryBot.definition_file_paths << File.expand_path('test/factories', __dir__)
  FactoryBot.find_definitions
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

def teardown_db
  tables = ActiveRecord::Base.connection.data_sources
  tables.each do |table|
    ActiveRecord::Base.connection.truncate(table)
  end
end
teardown_db
