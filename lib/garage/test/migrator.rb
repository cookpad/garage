require "generators/doorkeeper/templates/migration"

module Garage
  module Test
    module Migrator
      extend ActiveSupport::Concern

      included do
        before(:all) do
          silence_stream(STDOUT) do
            begin
              CreateDoorkeeperTables.migrate(:up)
            rescue ActiveRecord::StatementInvalid
              # Rescue exceptions if the tables are already created.
            end
          end
        end

        after(:all) do
          silence_stream(STDOUT) do
            begin
              CreateDoorkeeperTables.migrate(:down)
            rescue ActiveRecord::StatementInvalid
              # Rescue exceptions if the tables are already created.
            end
          end
        end
      end
    end
  end
end
