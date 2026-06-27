require 'test_helper'

class TimeTokenVerifierTest < ActiveSupport::TestCase
  test "should generate and verify valid token" do
    campaign_id = 42
    timestamp = Time.current.to_i
    token = TimeTokenVerifier.generate(campaign_id, timestamp)
    
    assert TimeTokenVerifier.verify?(campaign_id, timestamp, token)
  end

  test "should fail for old timestamp" do
    campaign_id = 42
    timestamp = 20.minutes.ago.to_i
    token = TimeTokenVerifier.generate(campaign_id, timestamp)

    assert_not TimeTokenVerifier.verify?(campaign_id, timestamp, token)
  end

  test "should fail for incorrect token" do
    campaign_id = 42
    timestamp = Time.current.to_i
    
    assert_not TimeTokenVerifier.verify?(campaign_id, timestamp, "invalid_token")
  end
end
