module Garage
  module Test
    module Migrator
      extend ActiveSupport::Concern

      included do
        before(:all) do
          silence_stream(STDOUT) { Garage::Test::Migration.up }
        end

        after(:all) do
          silence_stream(STDOUT) { Garage::Test::Migration.down }
        end
      end
    end

    class Migration < ActiveRecord::Migration
      def self.up
        create_table :oauth_applications do |t|
          t.string  :name,         :null => false
          t.string  :uid,          :null => false
          t.string  :secret,       :null => false
          t.string  :redirect_uri, :null => false, :limit => 2048
          t.timestamps
        end

        add_index :oauth_applications, :uid, :unique => true

        create_table :oauth_access_grants do |t|
          t.integer  :resource_owner_id, :null => false
          t.integer  :application_id,    :null => false
          t.string   :token,             :null => false
          t.integer  :expires_in,        :null => false
          t.string   :redirect_uri,      :null => false, :limit => 2048
          t.datetime :created_at,        :null => false
          t.datetime :revoked_at
          t.string   :scopes
        end

        add_index :oauth_access_grants, :token, :unique => true

        create_table :oauth_access_tokens do |t|
          t.integer  :resource_owner_id
          t.integer  :application_id,    :null => false
          t.string   :token,             :null => false
          t.string   :refresh_token
          t.integer  :expires_in
          t.datetime :revoked_at
          t.datetime :created_at,        :null => false
          t.string   :scopes
        end

        add_index :oauth_access_tokens, :token, :unique => true
        add_index :oauth_access_tokens, :resource_owner_id
        add_index :oauth_access_tokens, :refresh_token, :unique => true
      end

      def self.down
        drop_table :oauth_applications
        drop_table :oauth_access_tokens
        drop_table :oauth_access_grants
      end
    end
  end
end
