$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "garage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "the_garage"
  s.version     = Garage::VERSION
  s.authors     = ["Tatsuhiko Miyagawa"]
  s.email       = ["miyagawa@bulknews.net"]
  s.homepage    = "https://github.com/cookpad/garage"
  s.summary     = "Garage Platform Engine"
  s.description = "Garage extends your RESTful, Hypermedia APIs as a Platform"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", '>= 4.2.0'
  s.add_dependency "rack-accept-default", "~> 0.0.2"
  s.add_dependency "oj"
  s.add_dependency "responders"
  s.add_dependency "oauth2"
  s.add_dependency "redcarpet", ">= 3.1.1"
  s.add_dependency "haml"
  s.add_dependency "hashie"
  s.add_dependency "sassc-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "http_accept_language", ">= 2.0.0"
end
