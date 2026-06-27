class TimeTokenVerifier
  # Time window validity: 15 minutes (900 seconds)
  VALIDITY_WINDOW = 900

  def self.generate(campaign_id, timestamp)
    secret = Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE'] || "fallback_secret_key_base"
    OpenSSL::HMAC.hexdigest('SHA256', secret, "#{campaign_id}-#{timestamp}")
  end

  def self.verify?(campaign_id, timestamp, token)
    return false if campaign_id.blank? || timestamp.blank? || token.blank?

    # Verify that the timestamp is within the valid duration
    diff = (Time.current.to_i - timestamp.to_i).abs
    return false if diff > VALIDITY_WINDOW

    expected = generate(campaign_id, timestamp)
    ActiveSupport::SecurityUtils.secure_compare(token, expected)
  end
end
