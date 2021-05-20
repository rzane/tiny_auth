require "active_record"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/securerandom"

module TinyAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Find a resource by email, ignoring case
      # @param email [String]
      # @return [ActiveRecord::Base,nil]
      def find_by_email(email)
        find_by(arel_table[:email].lower.eq(email.downcase))
      end

      # Find a resource by their email address and password
      # This assumes that you've added `has_secure_password` to your model.
      # @param email [String]
      # @param password [String]
      # @return [ActiveRecord::Base,nil]
      def find_by_credentials(email, password)
        resource = find_by_email(email)
        resource if resource&.authenticate(password)
      end

      # Finds a resource by a token
      # @param token [String]
      # @param purpose [Symbol] defaults to `:access`
      # @return [ActiveRecord::Base,nil]
      def find_by_token(token, purpose: :access)
        id, token_version = TinyAuth.verifier.verify(token, purpose: purpose)
        find_by(id: id, token_version: token_version)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
      end
    end

    # Generates a token for this resource.
    # @param expires_in [ActiveSupport::Duration] defaults to 24 hours
    # @param purpose [Symbol] defaults to `:access`
    # @return [String]
    def generate_token(purpose: :access, expires_in: 24.hours)
      TinyAuth.verifier.generate(
        [id, token_version],
        purpose: purpose,
        expires_in: expires_in
      )
    end

    # Invalidate all tokens for this resource.
    # @return [self]
    def invalidate_tokens!
      increment!(:token_version)
    end

    # Whenever the password digest changes, all previously issued tokens
    # will be invalidated.
    # @param value [String] the new password digest
    # @return [String]
    def password_digest=(value)
      increment(:token_version)
      super
    end
  end
end
