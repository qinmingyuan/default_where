$:.push File.expand_path('../lib', __FILE__)
require 'default_where/version'

Gem::Specification.new do |s|
  s.name = 'default_where'
  s.version = DefaultWhere::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/qinmingyuan/default_where'
  s.summary = 'default process params for where'
  s.description = 'Description of QueryScope.'
  s.license = 'LGPL-3.0'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]
  s.test_files = Dir['test/**/*']

  s.add_runtime_dependency 'activerecord', '>= 4.0', '<= 6.0'
  s.add_development_dependency 'rdoc', '~> 0'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'factory_bot_rails', '~> 0'
end
