ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end

class ActionController::IntegrationTest
  def setup
    #UserSession.reset_inheritable_attributes
    get new_user_session_url # to active authgasm
  end
  
  def teardown
    Authgasm::Session::Base.controller = nil
  end
  
  private
    def assert_successful_login(login, password)
      post user_session_url, :user_session => {:login => login, :password => password}
      assert_redirected_to account_url
      follow_redirect!
      assert_template "users/show"
    end
  
    def assert_unsuccessful_login(login = nil, password = nil)
      params = (login || password) ? {:user_session => {:login => login, :password => password}} : nil
      post user_session_url, params
      assert_template "user_sessions/new"
    end
    
    def assert_successful_logout(alt_redirect = nil)
      redirecting_to = alt_redirect || new_user_session_url
      delete user_session_url
      assert_redirected_to redirecting_to # because I tried to access registration above, and it stored it
      follow_redirect!
      assert flash.key?(:notice)
      assert_equal nil, session["user_credentials"]
      assert_equal "", cookies["user_credentials"]
      assert_template redirecting_to.gsub("http://www.example.com/", "").gsub("user_session", "user_sessions").gsub("account", "users")
    end
  
    def assert_account_access(user = nil)
      user ||= users(:ben).reload
      # Perform multiple requests to make sure the session is persisting properly, just being anal here
      3.times do
        get account_url
        assert_equal user.remember_token, session["user_credentials"]
        assert_equal user.remember_token, cookies["user_credentials"]
        assert_response :success
        assert_template "users/show"
      end
    end
    
    def assert_no_account_access(alt_redirect = nil)
      get account_url
      assert_redirected_to alt_redirect || new_user_session_url
    end
end
