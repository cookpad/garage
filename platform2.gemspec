$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "platform2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "platform2"
  s.version     = Platform2::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Platform2."
  s.description = "TODO: Description of Platform2."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "doorkeeper", "~> 0.6.7"
  s.add_dependency "cancan", "~> 1.6.9"
  s.add_dependency "rack-accept-default", "~> 0.0.2"
  s.add_dependency "http_status_exceptions"
  s.add_dependency "yajl-ruby"

  s.add_dependency "tomdoc"
  s.add_dependency "oauth2"
  s.add_dependency "redcarpet"
  s.add_dependency "haml"
  s.add_dependency "sass-rails"
  s.add_dependency "coffee-rails"

  s.add_development_dependency "rspec-rails", "~> 2.12"
  s.add_development_dependency "sqlite3"
end
