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
  end
end