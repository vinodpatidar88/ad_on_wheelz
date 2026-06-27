class Reward < ApplicationRecord
  belongs_to :campaign
  has_many :user_profiles, dependent: :nullify

  REWARD_TYPES = %w[gift price trip].freeze

  validates :name, presence: true
  validates :reward_type, presence: true, inclusion: { in: REWARD_TYPES }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
