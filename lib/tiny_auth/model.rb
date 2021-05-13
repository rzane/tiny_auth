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
        find_by arel_table[:email].lower.eq(email.downcase)
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
      # @return [ActiveRecord::Base,nil]
      def find_by_token(token)
        find_by id: TinyAuth.verifier.verify(token, for: :access)
      end

      # Finds a resource by their reset token and nillifies `reset_password_digest`
      # and `reset_token_expires_at` fields
      # @param token [String]
      # @return [ActiveRecord::Base,nil]
      def exchange_reset_token(token)
        digest = TinyAuth.hexdigest(token)
        not_expired = arel_table[:reset_token_expires_at].gt(Time.now)
        resource = where(not_expired).find_by(reset_token_digest: digest)
        resource&.reset_token_digest = nil
        resource&.reset_token_expires_at = nil
        resource
      end
    end

    # Generates a stateless token for a resource
    # @param expires_in [ActiveSupport::Duration] defaults to 24 hours
    def generate_token(expires_in: 24.hours)
      TinyAuth.verifier.generate(id, expires_in: expires_in)
    end

    # Generates a reset token for a resource. A hashed version of the token
    # is stored in the database
    # @param expires_in [ActiveSupport::Duration] defaults to 2 hours
    def generate_reset_token(expires_in: 2.hours)
      token = SecureRandom.base58(24)
      digest = TinyAuth.hexdigest(token)
      expiry = expires_in.from_now

      update_columns(
        reset_token_digest: digest,
        reset_token_expires_at: expiry
      )

      token
    end
  end
end
