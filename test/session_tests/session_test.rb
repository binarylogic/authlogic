require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class SessionTest < ActiveSupport::TestCase
    def test_valid_session
      ben = users(:ben)
      session = UserSession.new
      
      assert !session.valid_session?
      
      set_session_for(ben)
      assert session.valid_session?
      assert session.find_record
      assert_equal ben, session.record
      assert_equal ben.persistence_token, @controller.session["user_credentials"]
      assert_equal ben, session.unauthorized_record
      assert !session.new_session?
    end
    
    def test_save
      ben = users(:ben)
      session = UserSession.new(ben)
      assert @controller.session["user_credentials"].blank?
      assert session.save
      assert_equal ben.persistence_token, @controller.session["user_credentials"]
    end
    
    def test_destroy
      ben = users(:ben)
      set_session_for(ben)
      assert_equal ben.persistence_token, @controller.session["user_credentials"]
      session = UserSession.find
      assert session.destroy
      assert @controller.session["user_credentials"].blank?
    end
    
    def test_find
      ben = users(:ben)
      set_cookie_for(ben)
      assert @controller.session["user_credentials"].blank?
      assert UserSession.find
      assert_equal ben.persistence_token, @controller.session["user_credentials"]
    end
  end
end