source "https://rubygems.org"

gem "rails", ">= 4.0.0"
gem "kaminari-activerecord"
gem "responders"
gem "order_query"

group :development, :test do
  gem "aws-xray", '>= 0.20.0'
  gem "rspec-rails"
  gem "mysql2"
  gem "pry-rails"
  gem "database_cleaner"
  gem "factory_bot"
  gem "factory_bot_rails"
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
