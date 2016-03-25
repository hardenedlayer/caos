class User < ActiveRecord::Base
  has_secure_password
  has_many :sessions
  has_many :albums

  validates :mail, length: { minimum: 3 }
end
