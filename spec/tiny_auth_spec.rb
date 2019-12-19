RSpec.describe TinyAuth do
  it "has a version number" do
    expect(TinyAuth::VERSION).not_to be nil
  end

  describe ".secret" do
    it "can be configured" do
      TinyAuth.secret = "foo"
      expect(TinyAuth.secret).to eq("foo")
    end

    it "raises an error if the secret is not set" do
      TinyAuth.secret = nil
      expect { TinyAuth.secret }.to raise_error(RuntimeError)
    end

    it "attempts to use Rails.application.secret_key_base" do
      application = double(secret_key_base: "foo")
      rails = double(application: application)
      stub_const("Rails", rails)

      TinyAuth.secret = nil
      expect(TinyAuth.secret).to eq("foo")
    end
  end

  describe ".hexdigest" do
    it "hashes a value" do
      expect(TinyAuth.hexdigest("foo")).to be_a(String)
    end

    it "is deterministic" do
      expect(TinyAuth.hexdigest("foo")).to eq(TinyAuth.hexdigest("foo"))
    end
  end
end
