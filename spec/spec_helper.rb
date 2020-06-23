ENV["RAILS_ENV"] ||= "test"
ENV['GARAGE_CONSOLE_APP_UID'] ||= 'dummy'
ENV['GARAGE_CONSOLE_APP_SECRET'] ||= 'dummy'

require "garage"

require File.expand_path("../dummy/config/environment", __FILE__)
require "rspec/rails"
require "webmock/rspec"
# XXX: Should remove runtime dependency later
require 'hashie'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.include FactoryBot::Syntax::Methods
  config.include RSpec::JsonMatcher, type: :request

  config.before(:each) do
    Rails.cache.clear
  end

  config.before(:each, type: :request) do
    %i[get post put delete].each do |name|
      define_singleton_method(name) do |path, params = {}, headers = {}|
        if Rails::VERSION::MAJOR >= 5
          super(path, params: params, headers: headers)
        else
          super(path, params, headers)
        end
      end
    end
  end
end
