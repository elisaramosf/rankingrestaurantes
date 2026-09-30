class Restaurant < ApplicationRecord
  belongs_to :category
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  validates :name, presence: true
  has_one_attached :photo
end
