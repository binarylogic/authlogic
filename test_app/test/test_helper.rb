ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
end

class ActionController::IntegrationTest
  def setup
    get new_user_session_url # to active authgasm
  end
  
  def teardown
    Authgasm::Session::Base.controller = nil
  end
  
  private
    def login_successfully(login, password)
      post user_session_url, :user_session => {:login => login, :password => password}
      assert_redirected_to account_url
      follow_redirect!
      assert_template "users/show"
    end
  
    def login_unsuccessfully(login = nil, password = nil)
      params = (login || password) ? {:user_session => {:login => login, :password => password}} : nil
      post user_session_url, params
      assert_template "user_sessions/new"
    end
  
    def access_account(user = nil)
      user ||= users(:ben)
      # Perform multiple requests to make sure the session is persisting properly, just being anal here
      3.times do
        get account_url
        assert_equal user.remember_token, session["user_credentials"]
        assert_equal user.remember_token, cookies["user_credentials"]
        assert_response :success
        assert_template "users/show"
      end
    end
  
    def logout(alt_redirect = nil)
      redirecting_to = alt_redirect || new_user_session_url
      delete user_session_url
      assert_redirected_to redirecting_to # because I tried to access registration above, and it stored it
      follow_redirect!
      assert flash.key?(:notice)
      assert_equal nil, session["user_credentials"]
      assert_equal "", cookies["user_credentials"]
      assert_template redirecting_to.gsub("http://www.example.com/", "").gsub("user_session", "user_sessions").gsub("account", "users")
    end
end
