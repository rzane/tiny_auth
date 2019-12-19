class User < ActiveRecord::Base
  include TinyAuth::Model
  has_secure_password
end
