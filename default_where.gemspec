$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "default_where/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "default_where"
  s.version     = DefaultWhere::VERSION
  s.authors     = ["qinmingyuan"]
  s.email       = ["mingyuan0715@foxmail.com"]
  s.homepage    = "https://github.com/qinmingyuan/default_where"
  s.summary     = "Summary of QueryScope."
  s.description = "Description of QueryScope."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"
end
