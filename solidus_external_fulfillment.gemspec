# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_external_fulfillment/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_external_fulfillment'
  s.version     = SolidusExternalFulfillment::VERSION
  s.summary     = 'External fulfillment functionality for Solidus'
  s.description = 'External fulfillment functionality for Solidus'

  s.author    = 'Per Gantelius'
  s.email     = 'per@stuffmatic.com'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core'
  s.add_dependency 'state_machines'
  s.add_dependency 'hashids'
  s.add_dependency 'deface'
  s.add_dependency 'redcarpet'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '1.16.0'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency "sqlite3", '~> 1.4'
end
