require "openssl"
require "tiny_auth/model"
require "tiny_auth/controller"
require "tiny_auth/version"
require "active_support/message_verifier"

module TinyAuth
  class << self
    # Configure the secret that is used for hashing tokens.
    # @param secret [String]
    def secret=(secret)
      @secret = secret
    end

    # The instance used to sign and verify tokens.
    # @return [ActiveSupport::MessageVerifier]
    def verifier
      ActiveSupport::MessageVerifier.new(secret)
    end

    # Create a hash from a value using the secret
    # @param value [String]
    # @return [String]
    def hexdigest(value)
      OpenSSL::HMAC.hexdigest("SHA256", secret, value)
    end

    private

    def secret
      @secret || raise("You need to configure TinyAuth.secret")
    end
  end
end

require "tiny_auth/railtie" if defined?(Rails::Railtie)
