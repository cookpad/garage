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

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "doorkeeper", "~> 0.6.7"
  s.add_dependency "rack-accept-default", "~> 0.0.2"
  s.add_dependency "http_status_exceptions"
  s.add_dependency "oj"

  s.add_dependency "oauth2"
  s.add_dependency "redcarpet"
  s.add_dependency "haml"
  s.add_dependency "sass-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "http_accept_language"
  s.add_dependency "font-awesome-rails"

  s.add_development_dependency "rspec-rails", "~> 2.12"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "quiet_assets"
end
