$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "garage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "garage"
  s.version     = Garage::VERSION
  s.authors     = ["Tatsuhiko Miyagawa"]
  s.email       = ["miyagawa@bulknews.net"]
  s.homepage    = "https://github.com/cookpad/garage"
  s.summary     = "Garage Platform Engine"
  s.description = "Garage extends your RESTful, Hypermedia APIs as a Platform"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '>= 4.0.0'
  s.add_dependency "doorkeeper", "~> 2.1.4"
  s.add_dependency "rack-accept-default", "~> 0.0.2"
  s.add_dependency "oj"
  s.add_dependency "responders"
  s.add_dependency "oauth2"
  s.add_dependency "redcarpet", ">= 3.1.1"
  s.add_dependency "haml"
  s.add_dependency "hashie"
  s.add_dependency "sass-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "http_accept_language", "~> 1.0.2"

  s.add_development_dependency "appraisal"
  s.add_development_dependency "rspec-rails" , "~> 2.14.0"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "quiet_assets"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "forgery"
  s.add_development_dependency "link_header"
  s.add_development_dependency "rspec-json_matcher", "0.1.2"
  s.add_development_dependency "webmock"
end
