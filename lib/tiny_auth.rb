require "openssl"
require "tiny_auth/model"
require "tiny_auth/version"

module TinyAuth
  class << self
    def secret
      @secret || secret_key_base || missing_secret!
    end

    def secret=(value)
      @secret = value
    end

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
