require 'test_helper'

module SessionTest
  class PersistenceTest < ActiveSupport::TestCase
    def test_find
      ben = users(:ben)
      assert !UserSession.find
      http_basic_auth_for(ben) { assert UserSession.find }
      set_cookie_for(ben)
      assert UserSession.find
      unset_cookie
      set_session_for(ben)
      session = UserSession.find
      assert session
    end
    
    def test_persisting
      # tested thoroughly in test_find
    end

    def test_should_set_remember_me_on_the_next_request
      ben = users(:ben)
      session = UserSession.new(ben)
      session.remember_me = true
      assert !UserSession.remember_me
      assert session.save
      assert session.remember_me?
      session = UserSession.find(ben)
      assert session.remember_me?
    end
  end
end
