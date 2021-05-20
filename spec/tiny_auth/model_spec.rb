RSpec.describe TinyAuth::Model do
  let(:email)    { "user@example.com" }
  let(:password) { "password" }
  let!(:user)    { User.create(email: email, password: password) }

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
    specify { expect(User.find_by_token("")).to be_nil }
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

  describe "#invalidate_tokens!" do
    it "invalidates tokens by changing the `token_version`" do
      token = user.generate_token
      expect(User.find_by_token(token)).to eq(user)

      user.invalidate_tokens!
      expect(User.find_by_token(token)).to be_nil
    end
  end

  context "when the password changes" do
    it "invalidates previously issued tokens" do
      token = user.generate_token
      expect(User.find_by_token(token)).to eq(user)

      user.update!(password: "changed")
      expect(User.find_by_token(token)).to be_nil
    end
  end

  context "when the password_digest changes" do
    it "invalidates previously issued tokens" do
      token = user.generate_token
      expect(User.find_by_token(token)).to eq(user)

      user.update!(password_digest: "changed")
      expect(User.find_by_token(token)).to be_nil
    end
  end
end
