require "openssl"
require "tiny_auth/model"
require "tiny_auth/controller"
require "tiny_auth/version"

module TinyAuth
  class << self
    # Configure the secret that is used for hashing tokens.
    # @param secret [String]
    def secret=(secret)
      @secret = secret
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
