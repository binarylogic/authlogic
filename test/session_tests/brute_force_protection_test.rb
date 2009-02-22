require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class BruteForceProtectionTest < ActiveSupport::TestCase
    def test_under_limit
      ben = users(:ben)
      ben.failed_login_count = UserSession.consecutive_failed_logins_limit - 1
      assert ben.save
      assert UserSession.create(:login => ben.login, :password => "benrocks")
    end

    def test_exceeded_limit
      ben = users(:ben)
      ben.failed_login_count = UserSession.consecutive_failed_logins_limit
      assert ben.save
      assert !UserSession.create(:login => ben.login, :password => "benrocks")
    end
    
    def test_exeeding_failed_logins_limit
      UserSession.consecutive_failed_logins_limit = 2
      ben = users(:ben)
      
      2.times do |i|
        session = UserSession.new(:login => ben.login, :password => "badpassword")
        assert !session.save
        assert session.errors.on(:password)
        assert_equal i + 1, ben.reload.failed_login_count
      end
      
      session = UserSession.new(:login => ben.login, :password => "badpassword2")
      assert !session.save
      assert !session.errors.on(:password)
      assert_equal 2, ben.reload.failed_login_count
      
      UserSession.consecutive_failed_logins_limit = 50
    end
    
    def test_resetting_failed_logins_count
      ben = users(:ben)
      
      2.times do |i|
        session = UserSession.new(:login => ben.login, :password => "badpassword")
        assert !session.save
        assert session.errors.on(:password)
        assert_equal i + 1, ben.reload.failed_login_count
      end
      
      session = UserSession.new(:login => ben.login, :password => "benrocks")
      assert session.save
      assert_equal 0, ben.reload.failed_login_count
    end
  end
end