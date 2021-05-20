require "base64"
require "active_support/message_verifier"

module TinyAuth
  class Verifier < ActiveSupport::MessageVerifier # :nodoc:
    private

    def encode(data)
      ::Base64.urlsafe_encode64(data)
    end

    def decode(data)
      ::Base64.urlsafe_decode64(data)
    end
  end
end
