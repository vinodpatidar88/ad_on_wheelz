class User < ApplicationRecord
  has_one :user_profile, dependent: :destroy

  validates :phone_number, presence: true, uniqueness: true
end
