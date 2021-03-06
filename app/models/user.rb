class User < ActiveRecord::Base
  has_secure_password
  has_many :sessions
  has_many :albums
  has_many :selections

  validates :mail, length: { minimum: 3 }
end
