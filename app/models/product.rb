class Product < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }

end
