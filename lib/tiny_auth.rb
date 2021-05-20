require "openssl"
require "tiny_auth/model"
require "tiny_auth/controller"
require "tiny_auth/version"
require "active_support/message_verifier"

module TinyAuth
  class << self
    # Configure the secret used to sign and verify tokens.
    # @param secret [String]
    def secret=(secret)
      @verifier = ActiveSupport::MessageVerifier.new(secret)
    end

    def verifier # :nodoc:
      @verifier || raise("Secret has not been configured")
    end
  end
end

require "tiny_auth/railtie" if defined?(Rails::Railtie)
