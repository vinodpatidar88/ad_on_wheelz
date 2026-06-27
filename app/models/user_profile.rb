class UserProfile < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :campaign
  belongs_to :reward, optional: true

  # States:
  # - draft: Reward selected
  # - otp_sent: OTP generated and sent
  # - otp_verified: Phone verified but user details not yet completed (captured for lead generation)
  # - completed: Form successfully filled and saved
  # - failed: Attempts failed
  STATUSES = %w[draft otp_sent otp_verified completed failed].freeze

  validates :status, inclusion: { in: STATUSES }

  # Conditional validation when status is completed
  validates :first_name, :last_name, :location_address, presence: true, if: :completed?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :completed?

  def completed?
    status == 'completed'
  end

  def otp_expired?
    otp_expires_at.nil? || Time.current > otp_expires_at
  end
end
