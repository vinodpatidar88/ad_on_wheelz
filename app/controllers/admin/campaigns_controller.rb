require 'prawn'
require 'rqrcode'

class Admin::CampaignsController < Admin::BaseController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :print]

  def index
    @campaigns = Campaign.all
  end

  def show
    # Generate QR Code SVG for inline preview in the show page
    qrcode = RQRCode::QRCode.new(public_campaign_url(qr_token: @campaign.qr_token, host: request.host_with_port))
    @qr_svg = qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  def new
    @campaign = Campaign.new
  end

  def edit
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_campaigns_path, notice: 'Campaign was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to admin_campaigns_path, notice: 'Campaign was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to admin_campaigns_path, notice: 'Campaign was successfully destroyed.'
  end

  def print
    qrcode = RQRCode::QRCode.new(public_campaign_url(qr_token: @campaign.qr_token, host: request.host_with_port))
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_margins_to: false,
      size: 240
    )

    pdf = Prawn::Document.new(page_size: "A4", margin: 40)
    
    # Title & Header
    pdf.font "Helvetica"
    pdf.text "Campaign Printing Sheet", size: 28, style: :bold, align: :center
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 25

    pdf.text "Campaign Name: #{@campaign.name}", size: 20, style: :bold
    pdf.move_down 5
    pdf.text "Sub Category: #{@campaign.sub_category.name}", size: 14, color: "444444"
    pdf.text "Category: #{@campaign.sub_category.category.name}", size: 14, color: "444444"
    pdf.move_down 15

    pdf.text "Validity Period: #{@campaign.start_date.strftime('%B %d, %Y')} to #{@campaign.end_date.strftime('%B %d, %Y')}", size: 12, style: :bold
    pdf.move_down 10
    pdf.text @campaign.description.to_s, size: 12, color: "333333"
    pdf.move_down 30

    # Draw QR code image
    pdf.image StringIO.new(png.to_s), position: :center, width: 220
    pdf.move_down 30

    pdf.text "SCAN QR CODE TO PARTICIPATE", align: :center, size: 16, style: :bold
    pdf.move_down 60

    pdf.stroke_horizontal_line 0, 500, at: 60
    pdf.draw_text "Printed via Rails AdOnWheels Admin Panel", at: [0, 40], size: 10, style: :italic

    send_data pdf.render, filename: "campaign_#{@campaign.qr_token}_qr.pdf", type: "application/pdf", disposition: "inline"
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:sub_category_id, :name, :description, :start_date, :end_date, :image)
  end
end
