$:.push File.expand_path('lib', __dir__)
require 'default_where/version'

Gem::Specification.new do |s|
  s.name = 'default_where'
  s.version = DefaultWhere::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/qinmingyuan/default_where'
  s.summary = 'default process params for where'
  s.description = 'Description of'
  s.license = 'LGPL-3.0'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]
  s.test_files = Dir['test/**/*']

  s.add_runtime_dependency 'activerecord', '>= 4.0', '<= 7.0'
  s.add_development_dependency 'sdoc', '~> 1.0'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'factory_bot_rails', '~> 4.11'
end
