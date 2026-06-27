class Admin::DashboardController < Admin::BaseController
  def index
    @total_campaigns = Campaign.count
    @total_profiles = UserProfile.count
    @completed_profiles = UserProfile.where(status: 'completed').count
    @incomplete_profiles = UserProfile.where.not(status: 'completed').count
    @recent_profiles = UserProfile.order(created_at: :desc).limit(10)
    @rewards_distributed = UserProfile.where(status: 'completed').where.not(reward_id: nil).count
  end
end
