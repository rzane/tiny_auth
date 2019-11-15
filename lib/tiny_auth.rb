require "tiny_auth/version"
require "globalid"
require "active_record"
require "active_support/core_ext/securerandom"

class TinyAuth
  class Error < StandardError; end
  class PersistError < StandardError; end

  def initialize(model, scope: model)
    @model = model
    @scope = scope
  end

  def find_by_email(email)
    @scope.find_by(@model.arel_table[:email].lower.eq(email.downcase))
  end

  def find_by_credentials(email, password)
    resource = find_by_email(email)
    resource if resource&.authenticate(password)
  end

  def generate_token(resource, purpose: :access, expires_in: 24.hours)
    resource.to_sgid(expires_in: expires_in, for: purpose)
  end

  def find_by_token(token, purpose: :access)
    GlobalID::Locator.locate_signed(token, for: purpose)
  end

  def generate_reset_token(resource, expires_in: 2.hours)
    update_reset(
      resource,
      reset_token: SecureRandom.base58(24),
      reset_token_expires_at: Time.now + expires_in
    )

    resource.reset_token
  end

  def exchange_reset_token(reset_token, changes = {})
    changes = changes.merge(reset_token: nil, reset_token_expires_at: nil)
    not_expired = @model.arel_table[:reset_token_expires_at].gt(Time.now)
    resource = @scope.where(not_expired).find_by(reset_token: reset_token)

    yield resource if resource && block_given?
    update_reset(resource, changes) if resource
  end

  private

  def update_reset(resource, changes)
    if resource.update(changes)
      resource
    else
      raise PersistError, "Failed to reset password."
    end
  end
end
