require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class TimeoutTest < ActiveSupport::TestCase
    def test_after_find
      ben = users(:ben)
      set_session_for(ben)
      session = UserSession.find
      assert session
      assert !session.record.last_request_at.nil?
      
      UserSession.last_request_at_threshold = 2.seconds
      assert_equal 2.seconds, UserSession.last_request_at_threshold

      assert UserSession.find
      last_request_at = ben.reload.last_request_at
      sleep(0.5)
      assert UserSession.find
      assert_equal last_request_at, ben.reload.last_request_at
      sleep(2)
      assert UserSession.find
      assert_not_equal last_request_at, ben.reload.last_request_at

      UserSession.last_request_at_threshold 0
      assert_equal 0, UserSession.last_request_at_threshold
    end
    
    def test_after_save
      ben = users(:ben)
      session = UserSession.new(ben)
      assert session.save
      assert !session.record.last_request_at.nil?
      assert !session.stale?
    end
    
    def test_not_stale
      UserSession.logout_on_timeout = true
      ben = users(:ben)
      ben.update_attribute(:last_request_at, Time.now)
      set_session_for(ben)
      session = UserSession.find
      assert !session.stale?
    end
    
    def test_stale
      ben = users(:ben)
      set_session_for(ben)
      ben.update_attribute(:last_request_at, 3.years.ago)
      session = UserSession.find
      assert session.stale?
      assert_nil @controller.session["user_credentials"]
      assert_nil @controller.session["user_credentials_id"]
      UserSession.logout_on_timeout = false
    end
    
    def test_stale_find
      UserSession.logout_on_timeout = true
      ben = users(:ben)
      
      ben.update_attribute(:last_request_at, 3.years.ago)
      set_session_for(ben)
      session = UserSession.find
      assert session.stale?
      
      ben.update_attribute(:last_request_at, Time.now)
      set_session_for(ben)
      session = UserSession.find
      assert !session.stale?
    end
  end
end