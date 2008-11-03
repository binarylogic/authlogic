ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end

class ActionController::IntegrationTest
  attr_accessor :scope
  
  def setup
    get new_user_session_url # to active authlogic
  end
  
  def teardown
    Authlogic::Session::Base.controller = nil
  end
  
  private
    def assert_successful_login(login, password)
      post scoped_url("user_session_url"), :user_session => {:login => login, :password => password}
      assert_redirected_to scoped_url("account_url")
      follow_redirect!
      assert_template "users/show"
    end
  
    def assert_unsuccessful_login(login = nil, password = nil)
      params = (login || password) ? {:user_session => {:login => login, :password => password}} : nil
      post scoped_url("user_session_url"), params
      assert_template "user_sessions/new"
    end
    
    def assert_successful_logout(alt_redirect = nil)
      redirecting_to = alt_redirect || scoped_url("new_user_session_url")
      delete scoped_url("user_session_url")
      assert_redirected_to redirecting_to # because I tried to access registration above, and it stored it
      follow_redirect!
      assert flash.key?(:notice)
      assert_equal nil, session[scoped_key]
      assert_equal "", cookies[scoped_key]
      assert_template redirecting_to.gsub("http://www.example.com/", "").gsub("user_session", "user_sessions").gsub("account", "users").gsub(/^companies\/[1-9]*\//, "")
    end
  
    def assert_account_access(user = nil)
      user ||= users(:ben).reload
      # Perform multiple requests to make sure the session is persisting properly, just being anal here
      3.times do
        get scoped_url("account_url")
        assert_equal user.remember_token, session[scoped_key]
        assert_equal user.remember_token, cookies[scoped_key]
        assert_response :success
        assert_template "users/show"
      end
    end
    
    def assert_no_account_access(alt_redirect = nil)
      get scoped_url("account_url")
      assert_redirected_to alt_redirect || scoped_url("new_user_session_url")
    end
    
    def scoped_url(unscoped_url, *args)
      case scope
      when Company
        regex = /^(new|edit)_/
        prefix = unscoped_url =~ regex ? "#{$1}_" : ""
        send("#{prefix}company_#{unscoped_url.gsub(regex, "")}", scope.id, *args)
      else
        send(unscoped_url, *args)
      end
    end
    
    def scoped_key
      parts = []
      parts << "#{scope.class.model_name.underscore}_#{scope.id}" if scope
      parts << "user_credentials"
      parts.join("_")
    end
end
