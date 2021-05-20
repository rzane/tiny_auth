RSpec.describe TinyAuth do
  it "has a version number" do
    expect(TinyAuth::VERSION).not_to be nil
  end

  describe ".secret" do
    it "can be configured" do
      TinyAuth.secret = "foo"
      expect(TinyAuth.verifier).to be_an(ActiveSupport::MessageVerifier)
    end

    it "raises an error if the secret is set to `nil`" do
      expect { TinyAuth.secret = nil }.to raise_error(ArgumentError, "Secret should not be nil.")
    end
  end

  describe ".verifier" do
    it "raises an error if the secret is not set" do
      TinyAuth.instance_variable_set(:@verifier, nil)
      expect { TinyAuth.verifier }.to raise_error(RuntimeError, "Secret has not been configured")
    end
  end
end
