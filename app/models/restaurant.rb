class Restaurant < ApplicationRecord
  belongs_to :category
  has_many :reviews
  has_many :favorites
  validates :name, presence: true
end
