require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class ConfigTest < ActiveSupport::TestCase
    def test_authenticate_with
      UserSession.authenticate_with = Employee
      assert_equal "Employee", UserSession.klass_name
      assert_equal Employee, UserSession.klass
    
      UserSession.authenticate_with User
      assert_equal "User", UserSession.klass_name
      assert_equal User, UserSession.klass
    end
  
    def test_cookie_key
      UserSession.cookie_key = "my_cookie_key"
      assert_equal "my_cookie_key", UserSession.cookie_key
      session = UserSession.new
      assert_equal "my_cookie_key", session.cookie_key
    
      UserSession.cookie_key "user_credentials"
      assert_equal "user_credentials", UserSession.cookie_key
      session = UserSession.new
      assert_equal "user_credentials", session.cookie_key
    end
  
    def test_find_by_login_method
      UserSession.find_by_login_method = "my_login_method"
      assert_equal "my_login_method", UserSession.find_by_login_method
      session = UserSession.new
      assert_equal "my_login_method", session.find_by_login_method
    
      UserSession.find_by_login_method "find_by_login"
      assert_equal "find_by_login", UserSession.find_by_login_method
      session = UserSession.new
      assert_equal "find_by_login", session.find_by_login_method
    end
  
    def test_find_with
      UserSession.find_with = [:session]
      assert_equal [:session], UserSession.find_with
      session = UserSession.new
      assert_equal [:session], session.find_with
    
      set_cookie_for(users(:ben))
      assert !UserSession.find
    
      UserSession.find_with :session, :cookie, :http_auth
      assert_equal [:session, :cookie, :http_auth], UserSession.find_with
      session = UserSession.new
      assert_equal [:session, :cookie, :http_auth], session.find_with
    
      assert UserSession.find
    end
    
    def test_last_request_at_threshold
      ben = users(:ben)
      set_session_for(ben)
      UserSession.last_request_at_threshold = 2.seconds
      assert_equal 2.seconds, UserSession.last_request_at_threshold
      
      assert UserSession.find
      last_request_at = ben.reload.last_request_at
      sleep(1)
      assert UserSession.find
      assert_equal last_request_at, ben.reload.last_request_at
      sleep(1)
      assert UserSession.find
      assert_not_equal last_request_at, ben.reload.last_request_at
      
      UserSession.last_request_at_threshold 0
      assert_equal 0, UserSession.last_request_at_threshold
    end
  
    def test_login_field
      UserSession.login_field = :saweet
      assert_equal :saweet, UserSession.login_field
      session = UserSession.new
      assert_equal :saweet, session.login_field
      assert session.respond_to?(:saweet)
    
      UserSession.login_field :login
      assert_equal :login, UserSession.login_field
      session = UserSession.new
      assert_equal :login, session.login_field
      assert session.respond_to?(:login)
    end
  
    def test_password_field
      UserSession.password_field = :saweet
      assert_equal :saweet, UserSession.password_field
      session = UserSession.new
      assert_equal :saweet, session.password_field
      assert session.respond_to?(:saweet)
    
      UserSession.password_field :password
      assert_equal :password, UserSession.password_field
      session = UserSession.new
      assert_equal :password, session.password_field
      assert session.respond_to?(:password)
    end
  
    def test_remember_me
      UserSession.remember_me = true
      assert_equal true, UserSession.remember_me
      session = UserSession.new
      assert_equal true, session.remember_me
    
      UserSession.remember_me false
      assert_equal false, UserSession.remember_me
      session = UserSession.new
      assert_equal false, session.remember_me
    end
  
    def test_remember_me_for
      UserSession.remember_me_for = 3.years
      assert_equal 3.years, UserSession.remember_me_for
      session = UserSession.new
      session.remember_me = true
      assert_equal 3.years, session.remember_me_for
    
      UserSession.remember_me_for 3.months
      assert_equal 3.months, UserSession.remember_me_for
      session = UserSession.new
      session.remember_me = true
      assert_equal 3.months, session.remember_me_for
    end
  
    def test_remember_token_field
      UserSession.remember_token_field = :saweet
      assert_equal :saweet, UserSession.remember_token_field
      session = UserSession.new
      assert_equal :saweet, session.remember_token_field
    
      UserSession.remember_token_field :remember_token
      assert_equal :remember_token, UserSession.remember_token_field
      session = UserSession.new
      assert_equal :remember_token, session.remember_token_field
    end
  
    def test_session_key
      UserSession.session_key = "my_session_key"
      assert_equal "my_session_key", UserSession.session_key
      session = UserSession.new
      assert_equal "my_session_key", session.session_key
    
      UserSession.session_key "user_credentials"
      assert_equal "user_credentials", UserSession.session_key
      session = UserSession.new
      assert_equal "user_credentials", session.session_key
    end
  
    def test_verify_password_method
      UserSession.verify_password_method = "my_login_method"
      assert_equal "my_login_method", UserSession.verify_password_method
      session = UserSession.new
      assert_equal "my_login_method", session.verify_password_method
    
      UserSession.verify_password_method "valid_password?"
      assert_equal "valid_password?", UserSession.verify_password_method
      session = UserSession.new
      assert_equal "valid_password?", session.verify_password_method
    end
  end
end