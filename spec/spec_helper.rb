require "bundler/setup"
require "tiny_auth"

GlobalID.app = 'auth'
SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new('sekret')

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Migration.verbose = false
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
  include GlobalID::Identification
  has_secure_password
  has_secure_token :reset_token
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
