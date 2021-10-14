FactoryBot.definition_file_paths << File.expand_path('../factories', __dir__)
FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
