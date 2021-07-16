class Product < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # 新增 setter
  def tag_list=(names)
    self.tags = names.split(',').map do |item|
      Tag.where(name: item.strip).first_or_create!
    end
  end

  # 新增 getter
  def tag_list
    tags.map(&:name).join(', ')
  end
end
