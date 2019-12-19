require "openssl"
require "tiny_auth/model"
require "tiny_auth/controller"
require "tiny_auth/version"

module TinyAuth
  class << self
    # A secret that is used for hashing tokens.
    #
    # If `Rails` is defined, it will attempt to use
    # `Rails.application.secret_key_base`.
    #
    # @raise [RuntimeError]
    # @return [String]
    def secret
      @secret || secret_key_base || missing_secret!
    end

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

    def secret_key_base
      Rails.application.secret_key_base if defined? Rails
    end

    def missing_secret!
      raise "You need to configure TinyAuth.secret"
    end
  end
end
