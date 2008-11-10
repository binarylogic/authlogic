require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class CookiesTest < ActiveSupport::TestCase
    def test_valid_cookie
      ben = users(:ben)
      session = UserSession.new
    
      assert !session.valid_cookie?
    
      set_cookie_for(ben)
      assert session.valid_cookie?
      assert_equal ben, session.unauthorized_record
    end
    
    def test_after_save_save_cookie
      ben = users(:ben)
      session = UserSession.new(ben)
      assert session.save
      assert_equal ben.remember_token, @controller.cookies["user_credentials"]
    end
    
    def test_after_destroy_destroy_cookie
      ben = users(:ben)
      set_cookie_for(ben)
      session = UserSession.find
      assert @controller.cookies["user_credentials"]
      assert session.destroy
      assert !@controller.cookies["user_credentials"]
    end
  end
end