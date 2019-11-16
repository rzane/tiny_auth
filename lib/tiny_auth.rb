require "tiny_auth/version"
require "globalid"
require "active_record"
require "active_support/core_ext/securerandom"

class TinyAuth
  def initialize(model, scope: model, secret: secret_key_base)
    @model = model
    @scope = scope
    @secret = secret

    raise ArgumentError, "missing argument: model" if model.nil?
    raise ArgumentError, "missing keyword: secret" if secret.nil?
  end

  def find_by_email(email)
    scope.find_by(model.arel_table[:email].lower.eq(email.downcase))
  end

  def find_by_credentials(email, password)
    resource = find_by_email(email)
    resource if resource&.authenticate(password)
  end

  def generate_token(resource, purpose: :access, expires_in: 24.hours)
    resource.to_sgid(expires_in: expires_in, for: purpose).to_s
  end

  def find_by_token(token, purpose: :access)
    GlobalID::Locator.locate_signed(token, for: purpose)
  rescue ActiveRecord::RecordNotFound
  end

  def generate_reset_token(resource, **opts)
    generate_single_use_token(resource, purpose: :reset, **opts)
  end

  def generate_single_use_token(resource, purpose:, expires_in: 2.hours)
    token = SecureRandom.base58(24)

    resource.update!(
      "#{purpose}_token" => hmac(token),
      "#{purpose}_token_expires_at" => expires_in.from_now
    )

    token
  end

  def exchange_reset_token(token, **opts, &block)
    exchange_single_use_token(token, purpose: :reset, **opts, &block)
  end

  def exchange_single_use_token(token, purpose:, update: {})
    not_expired = model.arel_table[:"#{purpose}_token_expires_at"].gt(Time.now)
    resource = scope.where(not_expired).find_by(:"#{purpose}_token" => hmac(token))

    return if resource.nil?
    yield resource if block_given?

    resource.assign_attributes(update)
    resource.update!("#{purpose}_token" => nil, "#{purpose}_token_expires_at" => nil)
    resource
  end

  private

  attr_reader :model, :scope, :secret

  def hmac(value)
    OpenSSL::HMAC.hexdigest("SHA256", secret, value)
  end

  def secret_key_base
    Rails.application.secret_key_base if defined?(Rails)
  end
end
