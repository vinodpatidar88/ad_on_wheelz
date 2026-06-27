require 'csv'
require 'prawn'
require 'prawn/table'

class Admin::UserProfilesController < Admin::BaseController
  before_action :set_user_profile, only: [:show, :update]

  def index
    @user_profiles = UserProfile.includes(:user, :campaign, :reward).order(created_at: :desc)

    # Filter by Date Range
    if params[:start_date].present?
      @user_profiles = @user_profiles.where('user_profiles.created_at >= ?', Date.parse(params[:start_date]).beginning_of_day)
    end
    if params[:end_date].present?
      @user_profiles = @user_profiles.where('user_profiles.created_at <= ?', Date.parse(params[:end_date]).end_of_day)
    end

    # Filter by Campaign
    if params[:campaign_id].present?
      @user_profiles = @user_profiles.where(campaign_id: params[:campaign_id])
    end

    # Filter by Status
    if params[:status].present?
      @user_profiles = @user_profiles.where(status: params[:status])
    end

    # Handle Exports
    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv(@user_profiles), filename: "user_profiles_#{Time.current.to_i}.csv", type: 'text/csv'
      end
      format.pdf do
        send_data generate_pdf(@user_profiles), filename: "user_profiles_#{Time.current.to_i}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def show
  end

  def update
    if @user_profile.update(user_profile_params)
      redirect_to admin_user_profile_path(@user_profile), notice: 'User Profile was successfully updated.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_user_profile
    @user_profile = UserProfile.find(params[:id])
  end

  def user_profile_params
    params.require(:user_profile).permit(:status, :feedback)
  end

  def generate_csv(profiles)
    CSV.generate(headers: true) do |csv|
      csv << [
        'Profile ID', 'User ID', 'Phone Number', 'Phone Verified', 
        'Campaign', 'Reward Type', 'Reward Name', 'First Name', 
        'Last Name', 'Email', 'IP Address', 'Location Address', 
        'Status', 'OTP Attempts', 'Feedback', 'Created At'
      ]
      profiles.each do |p|
        csv << [
          p.id,
          p.user_id,
          p.user&.phone_number,
          p.user&.verified,
          p.campaign&.name,
          p.reward&.reward_type,
          p.reward&.name,
          p.first_name,
          p.last_name,
          p.email,
          p.ip_address,
          p.location_address,
          p.status,
          p.otp_attempts,
          p.feedback,
          p.created_at.strftime('%Y-%m-%d %H:%M:%S')
        ]
      end
    end
  end

  def generate_pdf(profiles)
    pdf = Prawn::Document.new(page_size: 'A4', page_layout: :landscape, margin: 20)
    pdf.font 'Helvetica'
    
    # Title & Metadata
    pdf.text "User Profiles Report", size: 24, style: :bold
    pdf.text "Generated: #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 10, color: '666666'
    pdf.text "Filters - Date: #{params[:start_date].presence || 'Any'} to #{params[:end_date].presence || 'Any'} | Campaign: #{params[:campaign_id].present? ? Campaign.find(params[:campaign_id]).name : 'All'} | Status: #{params[:status].presence || 'All'}", size: 10, color: '666666'
    pdf.move_down 20

    # Table content
    headers = ['ID', 'Phone', 'Campaign', 'Reward', 'Name', 'Email', 'IP Address', 'Status', 'Feedback', 'Date']
    data = [headers]

    profiles.each do |p|
      data << [
        p.id.to_s,
        p.user&.phone_number || 'N/A',
        p.campaign&.name.to_s.truncate(15),
        p.reward ? "#{p.reward.reward_type.capitalize}: #{p.reward.name.truncate(12)}" : 'None',
        "#{p.first_name} #{p.last_name}".strip.presence || 'N/A',
        p.email || 'N/A',
        p.ip_address || 'N/A',
        p.status.upcase,
        p.feedback.to_s.truncate(15).presence || '-',
        p.created_at.strftime('%m/%d/%Y')
      ]
    end

    pdf.table(data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = '1F2937' # Dark slate header
      row(0).text_color = 'FFFFFF'
      self.row_colors = ['FFFFFF', 'F3F4F6']
      self.cell_style = { size: 8, padding: 6, border_color: 'E5E7EB' }
    end

    pdf.render
  end
end
