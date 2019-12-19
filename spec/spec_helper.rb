require "bundler/setup"
require_relative "support/coverage"
require "bcrypt"
require "tiny_auth"
require_relative "support/schema"
require_relative "support/models"
require_relative "support/controller"

# Configure GlobalID
GlobalID.app = "auth"
SignedGlobalID.verifier = ActiveSupport::MessageVerifier.new("sekret")
ActiveRecord::Base.send :include, GlobalID::Identification

# Make Bcrypt faster for tests
BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    TinyAuth.secret = "abcdefg"
  end

  config.before :each do
    User.delete_all
  end
end
