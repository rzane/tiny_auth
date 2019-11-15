require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "tiny_auth"
require "bcrypt"

# Configure GlobalID
GlobalID.app = "auth"
SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new("sekret")
ActiveRecord::Base.send :include, GlobalID::Identification

# Make Bcrypt faster for tests
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

# Setup the database
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email, null: false
    t.string :password_digest, null: false
    t.string :reset_token
    t.datetime :reset_token_expires_at
    t.index :email, unique: true
    t.index :reset_token, unique: true
  end
end

class User < ActiveRecord::Base
  has_secure_password
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    User.delete_all
  end
end
