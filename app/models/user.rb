class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :reviews
  has_many :favorites

  enum :role, { user: "user", owner: "owner", admin: "admin" }, default: :user

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, uniqueness: true
end
