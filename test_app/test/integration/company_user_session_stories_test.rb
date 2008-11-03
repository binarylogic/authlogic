require 'test_helper'

class CompanyUserSessionStoriesTest < ActionController::IntegrationTest
  def setup
    super
    self.scope = Company.first
  end
  
  def test_login_process
    # Try to access the company account area without being logged in
    get scoped_url("account_url")
    assert_redirected_to scoped_url("new_user_session_url")
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "user_sessions/new"
    
    # Try to login unsuccessfully
    assert_unsuccessful_login
    assert_unsuccessful_login("bjohnson", "badpassword")
    assert_unsuccessful_login("zham", "zackrocks") # this is correct, but zack does not belong to this company
    
    assert_successful_login("bjohnson", "benrocks")
    
    # Try to log in again after a successful login
    get scoped_url("new_user_session_url")
    assert_redirected_to scoped_url("account_url")
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    # Try to register after a successful login
    get scoped_url("new_account_url")
    assert_redirected_to scoped_url("account_url")
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    assert_account_access
    assert_successful_logout(scoped_url("new_account_url")) # before I tried to register, it stored my location
    
    # Try to access my account again
    get scoped_url("account_url")
    assert_redirected_to scoped_url("new_user_session_url")
    assert flash.key?(:notice)
  end
end