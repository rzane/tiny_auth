RSpec.describe TinyAuth do
  subject(:auth) { TinyAuth.new(User) }
  let(:email)    { 'user@example.com' }
  let(:password) { 'password' }
  let!(:user)    { User.create(email: email, password: password) }

  it "has a version number" do
    expect(TinyAuth::VERSION).not_to be nil
  end

  describe "#find_by_email" do
    specify { expect(auth.find_by_email(email)).to eq(user) }
    specify { expect(auth.find_by_email(email.upcase)).to eq(user) }
    specify { expect(auth.find_by_email("")).to be_nil }
  end

  describe "#find_by_credentials" do
    specify { expect(auth.find_by_credentials(email, password)).to eq(user) }
    specify { expect(auth.find_by_credentials(email.upcase, password)).to eq(user) }
    specify { expect(auth.find_by_credentials(email, "")).to be_nil }
    specify { expect(auth.find_by_credentials("", password)).to be_nil }
  end

  describe "#generate_token and #find_by_token" do
    let(:token) { auth.generate_token(user) }

    specify { expect(auth.find_by_token(token)).to eq(user) }
    specify { expect(auth.find_by_token('')).to be_nil }
    specify { expect(auth.find_by_token(nil)).to be_nil }
    specify { expect(auth.find_by_token(token, purpose: :invalid)).to be_nil }

    context "using an expired token" do
      let(:token) { auth.generate_token(user, expires_in: -1.hour) }

      specify { expect(auth.find_by_token(token)).to be_nil }
    end

    context "using a token with a custom purpose" do
      let(:token) { auth.generate_token(user, purpose: :custom) }

      specify { expect(auth.find_by_token(token)).to be_nil }
      specify { expect(auth.find_by_token(token, purpose: :custom)).to eq(user) }
    end
  end

  describe "#generate_reset_token" do
    let(:reset_token) { auth.generate_reset_token(user) }

    it "is a string" do
      expect(reset_token).to be_a(String)
    end

    it "assigns a reset_token" do
      expect { reset_token }.to change { user.reload.reset_token }
    end

    it "assigns an expiration" do
      expect { reset_token }.to change { user.reload.reset_token_expires_at }
    end
  end

  describe "#exchange_reset_token" do
    let!(:reset_token) { auth.generate_reset_token(user) }

    def exchange(*args, &block)
      auth.exchange_reset_token(reset_token, *args, &block)
    end

    it "returns the user" do
      expect(exchange).to eq(user)
    end

    it "yields the user" do
      expect { |b| exchange(&b) }.to yield_with_args(user)
    end

    it "accepts attributes for update" do
      expect {
        exchange(email: 'changed@example.com')
      }.to change { user.reload.email }
    end

    it "accepts a block for update" do
      expect {
        exchange do |user|
          user.email = 'changed@example.com'
        end
      }.to change { user.reload.email }
    end

    it "clears the reset token" do
      expect { exchange }.to change { user.reload.reset_token }.to(nil)
    end

    it "clears the expiration" do
      expect { exchange }.to change { user.reload.reset_token_expires_at }.to(nil)
    end

    context "when the token is expired" do
      let(:reset_token) { auth.generate_reset_token(user, expires_in: -1) }

      it "returns nil" do
        expect(exchange).to be_nil
      end

      it "does not yield" do
        expect { |b| exchange(&b) }.not_to yield_control
      end
    end
  end
end
