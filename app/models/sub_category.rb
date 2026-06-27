class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :campaigns, dependent: :destroy

  validates :name, presence: true
end
