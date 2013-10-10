require "generators/doorkeeper/templates/migration"

module Garage
  module Test
    module Migrator
      extend ActiveSupport::Concern

      included do
        before(:all) do
          silence_stream(STDOUT) { CreateDoorkeeperTables.up }
        end

        after(:all) do
          silence_stream(STDOUT) { CreateDoorkeeperTables.down }
        end
      end
    end
  end
end
