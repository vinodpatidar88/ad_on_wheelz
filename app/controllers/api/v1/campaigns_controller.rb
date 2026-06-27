class Api::V1::CampaignsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_campaign
  before_action :verify_secure_token

  # Step 1: Select Reward. Initializes the UserProfile draft.
  def select_reward
    reward = @campaign.rewards.find(params[:reward_id])
    
    if reward.stock <= 0
      render json: { error: 'This reward is out of stock' }, status: :unprocessable_entity
      return
    end

    profile = @campaign.user_profiles.create!(
      reward: reward,
      status: 'draft'
    )

    render json: { 
      message: 'Reward selected successfully', 
      user_profile_id: profile.id 
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Reward not found' }, status: :not_found
  end

  # Step 2a: Send OTP to phone number
  def send_otp
    profile = @campaign.user_profiles.find(params[:user_profile_id])
    phone = params[:phone_number].to_s.strip

    if phone.blank?
      render json: { error: 'Phone number is required' }, status: :unprocessable_entity
      return
    end

    # Find or create User
    user = User.find_or_create_by!(phone_number: phone)

    # Generate OTP
    otp = rand(100000..999999).to_s
    profile.update!(
      user: user,
      otp_code: otp,
      otp_expires_at: 10.minutes.from_now,
      otp_attempts: 0,
      status: 'otp_sent'
    )

    # Simulate sending
    Rails.logger.info "[OTP SIMULATION] Sent OTP #{otp} to #{phone}"

    # In development or testing environment, we send the OTP back in JSON for preview/testing ease.
    response_data = { message: 'OTP sent successfully' }
    if Rails.env.development? || Rails.env.test?
      response_data[:simulated_otp] = otp
    end

    render json: response_data
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Profile session not found' }, status: :not_found
  end

  # Step 2b: Verify OTP
  def verify_otp
    profile = @campaign.user_profiles.find(params[:user_profile_id])
    otp = params[:otp_code].to_s.strip

    if profile.otp_expired?
      profile.update!(status: 'failed')
      render json: { error: 'OTP has expired. Please request a new one.' }, status: :unprocessable_entity
      return
    end

    if profile.otp_attempts >= 5
      profile.update!(status: 'failed')
      render json: { error: 'Too many incorrect attempts. Please request a new OTP.' }, status: :unprocessable_entity
      return
    end

    if profile.otp_code == otp
      profile.user.update!(verified: true)
      profile.update!(status: 'otp_verified')
      render json: { message: 'OTP verified successfully' }
    else
      profile.increment!(:otp_attempts)
      render json: { error: 'Invalid OTP code' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Profile session not found' }, status: :not_found
  end

  # Step 3: Save User Details
  def save_profile
    profile = @campaign.user_profiles.find(params[:user_profile_id])

    unless profile.status == 'otp_verified' || profile.status == 'completed'
      render json: { error: 'Please verify your phone number first' }, status: :forbidden
      return
    end

    # Update profile fields and set status to completed
    profile.assign_attributes(
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      location_address: params[:location_address],
      feedback: params[:feedback],
      ip_address: request.remote_ip,
      status: 'completed'
    )

    if profile.save
      # Decrement reward stock
      if profile.reward.present? && profile.reward.stock > 0
        profile.reward.decrement!(:stock)
      end
      render json: { message: 'Profile saved successfully', reward_name: profile.reward&.name }
    else
      # Save failed state info so we don't lose the draft user info (selling purpose)
      profile.update_columns(
        first_name: params[:first_name],
        last_name: params[:last_name],
        email: params[:email],
        location_address: params[:location_address]
      )
      render json: { error: profile.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Profile session not found' }, status: :not_found
  end

  private

  def set_campaign
    @campaign = Campaign.find_by!(qr_token: params[:qr_token])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Campaign not found' }, status: :not_found
  end

  def verify_secure_token
    token = request.headers['X-Time-Token'] || params[:time_token]
    timestamp = request.headers['X-Time-Stamp'] || params[:timestamp]

    unless TimeTokenVerifier.verify?(@campaign.id, timestamp, token)
      render json: { error: 'Secure token verification failed or expired' }, status: :unauthorized
    end
  end
end
