require "tiny_auth/controller"
require "tiny_auth/model"
require "tiny_auth/verifier"
require "tiny_auth/version"

module TinyAuth
  class << self
    # Configure the secret used to sign and verify tokens.
    # @param secret [String]
    def secret=(secret)
      @verifier = Verifier.new(secret)
    end

    def verifier # :nodoc:
      @verifier || raise("Secret has not been configured")
    end
  end
end

begin
  require "rails/railtie"
rescue LoadError
else
  require "tiny_auth/railtie"
end
