require "active_record"
require "globalid"
require "active_support/core_ext/securerandom"

module TinyAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find_by_email(email)
        find_by arel_table[:email].lower.eq(email.downcase)
      end

      def find_by_credentials(email, password)
        resource = find_by_email(email)
        resource if resource&.authenticate(password)
      end

      def find_by_token(token, purpose: :access)
        resource = GlobalID::Locator.locate_signed(token, for: purpose)
        resource if resource.kind_of?(self)
      rescue ActiveRecord::RecordNotFound
      end

      def exchange_reset_token(token)
        digest = TinyAuth.hexdigest(token)
        not_expired = arel_table[:reset_token_expires_at].gt(Time.now)
        resource = where(not_expired).find_by(reset_token_digest: digest)
        resource&.update_columns(reset_token_digest: nil, reset_token_expires_at: nil)
        resource
      end
    end

    def generate_token(expires_in: 24.hours, purpose: :access)
      to_signed_global_id(expires_in: expires_in, for: purpose).to_s
    end

    def generate_reset_token(expires_in: 2.hours)
      token = SecureRandom.base58(24)
      digest = TinyAuth.hexdigest(token)

      update_columns(
        reset_token_digest: digest,
        reset_token_expires_at: expires_in.from_now
      )

      token
    end
  end
end
