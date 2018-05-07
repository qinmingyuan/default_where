# $DEBUG = true

require "rubygems"
require "bundler/setup"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "active_record"
require "minitest/autorun"

db_config = YAML.load_file(File.expand_path('database.yml', __dir__)).fetch(ENV["DB"] || "mysql")
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Schema.verbose = false

def teardown_db
  tables = ActiveRecord::Base.connection.data_sources
  tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end