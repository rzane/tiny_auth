module TinyAuth
  class Railtie < Rails::Railtie # :nodoc:
    initializer "tiny_auth" do |app|
      TinyAuth.secret = app.key_generator.generate_key("tiny_auth")
    end
  end
end
