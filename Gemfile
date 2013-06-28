source "https://rubygems.org"

gem "rails", "~> 3.2.11"
gem "cancan"
gem "kaminari"

group :test do
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "forgery"
  gem "link_header"
  gem "database_cleaner"
end

group :development, :test do
  gem "mysql2"
  gem "rspec-rails"
end

# Declare your gem's dependencies in garage.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"
