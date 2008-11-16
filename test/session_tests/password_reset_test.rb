require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class PasswordResetTest < ActiveSupport::TestCase
    def test_after_save
      ben = users(:ben)
      old_password_reset_token = ben.password_reset_token
      session = UserSession.create(ben)
      assert_not_equal old_password_reset_token, ben.password_reset_token
      
      drew = employees(:drew)
      assert UserSession.create(drew)
    end
  end
end