class PublicCampaignsController < ApplicationController
  layout 'public_campaign'

  def show
    @campaign = Campaign.find_by!(qr_token: params[:qr_token])

    unless @campaign.active?
      render :inactive, status: :forbidden and return
    end

    # Group rewards by type
    @rewards = @campaign.rewards.where('stock > 0').group_by(&:reward_type)

    # Generate initial secure time-based token
    @timestamp = Time.current.to_i
    @time_token = TimeTokenVerifier.generate(@campaign.id, @timestamp)
  end
end
