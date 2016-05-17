source "https://rubygems.org"

gem "rails", ">= 4.0.0"
gem "kaminari"
gem "responders"

group :development, :test do
  gem "rspec-rails"
  gem "mysql2"
  gem "pry-rails"
  gem "database_cleaner"
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "forgery"
  gem "link_header"
  gem "rspec-json_matcher"
end

group :development do
  gem "puma"
end

group :test do
  gem "webmock"
  gem "timecop"
end

# Declare your gem's dependencies in garage.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
