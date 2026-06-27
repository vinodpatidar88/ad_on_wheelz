class Campaign < ApplicationRecord
  belongs_to :sub_category
  has_many :rewards, dependent: :destroy
  has_many :user_profiles, dependent: :nullify

  has_one_attached :image

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :qr_token, presence: true, uniqueness: true

  before_validation :generate_qr_token, on: :create

  def active?
    now = Time.current
    start_date <= now && now <= end_date
  end

  private

  def generate_qr_token
    self.qr_token ||= SecureRandom.alphanumeric(12)
  end
end
