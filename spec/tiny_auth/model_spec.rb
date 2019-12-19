RSpec.describe TinyAuth::Model do
  let(:email)    { "user@example.com" }
  let(:password) { "password" }
  let!(:user)    { User.create(email: email, password: password) }

  before do
    TinyAuth.secret = "abcdefg"
  end

  describe "#find_by_email" do
    specify { expect(User.find_by_email(email)).to eq(user) }
    specify { expect(User.find_by_email(email.upcase)).to eq(user) }
    specify { expect(User.find_by_email("")).to be_nil }
  end

  describe "#find_by_credentials" do
    specify { expect(User.find_by_credentials(email, password)).to eq(user) }
    specify { expect(User.find_by_credentials(email.upcase, password)).to eq(user) }
    specify { expect(User.find_by_credentials(email, "")).to be_nil }
    specify { expect(User.find_by_credentials("", password)).to be_nil }
  end

  describe "#generate_token" do
    specify { expect(user.generate_token).to be_a(String) }
  end

  describe "#find_by_token" do
    let(:token) { user.generate_token }

    specify { expect(User.find_by_token(token)).to eq(user) }
    specify { expect(User.find_by_token('')).to be_nil }
    specify { expect(User.find_by_token(nil)).to be_nil }

    it "ignores non-existent records" do
      user.destroy
      expect(User.find_by_token(token)).to be_nil
    end

    context "using an expired token" do
      let(:token) { user.generate_token(expires_in: -1.hour) }

      specify { expect(User.find_by_token(token)).to be_nil }
    end
  end

  describe "#generate_reset_token" do
    let(:reset_token) { user.generate_reset_token }

    it "is a string" do
      expect(reset_token).to be_a(String)
    end

    it "assigns reset_token_digest" do
      expect { reset_token }.to change { user.reload.reset_token_digest }
    end

    it "assigns reset_token_expires_at" do
      expect { reset_token }.to change { user.reload.reset_token_expires_at }
    end
  end

  describe "#exchange_reset_token" do
    let!(:reset_token) { user.generate_reset_token }

    it "returns the user" do
      expect(User.exchange_reset_token(reset_token)).to eq(user)
    end

    it "nullifies reset_token_digest" do
      user = User.exchange_reset_token(reset_token)
      expect(user.reset_token_digest).to be_nil
    end

    it "nullifies reset_token_expires_at" do
      user = User.exchange_reset_token(reset_token)
      expect(user.reset_token_expires_at).to be_nil
    end

    context "when the token is expired" do
      let(:reset_token) { user.generate_reset_token(expires_in: -1.hour) }

      it "returns nil" do
        expect(User.exchange_reset_token(reset_token)).to be_nil
      end
    end

    context "when the token is pure baloney" do
      let(:reset_token) { "baloney" }

      it "returns nil" do
        expect(User.exchange_reset_token(reset_token)).to be_nil
      end
    end
  end
end
