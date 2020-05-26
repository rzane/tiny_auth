class TestController
  extend TinyAuth::Controller

  attr_accessor :request

  authenticates model: User
  authenticates model: User, name: :person

  def initialize(request)
    self.request = request
  end
end


RSpec.describe TinyAuth::Controller do
  describe ".token" do
    it "is nil when authorization is not provided" do
      request = double(authorization: nil)
      token = described_class.token(request)
      expect(token).to be_nil
    end

    it "is nil when authorization is blank" do
      request = double(authorization: "")
      token = described_class.token(request)
      expect(token).to be_nil
    end

    it "is nil when authorization is not Bearer" do
      request = double(authorization: "Token foo")
      token = described_class.token(request)
      expect(token).to be_nil
    end

    it "is nil when token is blank" do
      request = double(authorization: "Bearer ")
      token = described_class.token(request)
      expect(token).to be_nil
    end

    it "parse a token" do
      request = double(authorization: "Bearer foo")
      token = described_class.token(request)
      expect(token).to eq("foo")
    end
  end

  describe ".authenticates" do
    let!(:user) { User.create!(email: "user@example.com", password: "password") }
    let(:authorization) { "Bearer #{user.generate_token}" }
    let(:request) { double(authorization: authorization) }
    let(:controller) { TestController.new(request) }

    it "finds the current_user" do
      expect(controller.authenticate_user).to eq(user)
      expect(controller.current_user).to eq(user)
      expect(controller.user_signed_in?).to be(true)
    end

    it "finds the current person" do
      expect(controller.authenticate_person).to eq(user)
      expect(controller.current_person).to eq(user)
      expect(controller.person_signed_in?).to be(true)
    end

    context "when a token is not valid" do
      let(:authorization) { "Bearer baloney" }

      it "does not find the current_user" do
        expect(controller.current_user).to be_nil
        expect(controller.user_signed_in?).to be(false)
      end

      it "does not find the current_person" do
        expect(controller.current_person).to be_nil
        expect(controller.person_signed_in?).to be(false)
      end
    end
  end
end
