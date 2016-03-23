class User < ActiveRecord::Base
  has_secure_password
  has_many :sessions

  validates :mail, length: { minimum: 3 }
end
