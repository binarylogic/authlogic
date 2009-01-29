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
    
    def test_disable_magic_states
      UserSession.disable_magic_states = true
      assert_equal true, UserSession.disable_magic_states
      session = UserSession.new
      assert_equal true, session.disable_magic_states?
    
      UserSession.disable_magic_states false
      assert_equal false, UserSession.disable_magic_states
      session = UserSession.new
      assert_equal false, session.disable_magic_states?
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
      UserSession.last_request_at_threshold = 2.minutes
      assert_equal 2.minutes, UserSession.last_request_at_threshold
      session = UserSession.new
      assert_equal 2.minutes, session.last_request_at_threshold
    
      UserSession.last_request_at_threshold 0
      assert_equal 0, UserSession.last_request_at_threshold
      session = UserSession.new
      assert_equal 0, session.last_request_at_threshold
    end
    
    def test_login_field
      UserSession.methods_configured = false
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
    
    def test_params_key
      UserSession.params_key = "my_params_key"
      assert_equal "my_params_key", UserSession.params_key
      session = UserSession.new
      assert_equal "my_params_key", session.params_key
    
      UserSession.params_key "user_credentials"
      assert_equal "user_credentials", UserSession.params_key
      session = UserSession.new
      assert_equal "user_credentials", session.params_key
    end
  
    def test_password_field
      UserSession.methods_configured = false
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
    
    def test_single_access_allowed_request_types
      UserSession.single_access_allowed_request_types = "my request type"
      assert_equal ["my request type"], UserSession.single_access_allowed_request_types
      session = UserSession.new
      assert_equal ["my request type"], session.single_access_allowed_request_types
    
      UserSession.single_access_allowed_request_types "application/rss+xml", "application/atom+xml"
      assert_equal ["application/rss+xml", "application/atom+xml"], UserSession.single_access_allowed_request_types
      session = UserSession.new
      assert_equal ["application/rss+xml", "application/atom+xml"], session.single_access_allowed_request_types
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