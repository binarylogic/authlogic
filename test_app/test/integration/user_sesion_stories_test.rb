require 'test_helper'

class UserSessionStoriesTest < ActionController::IntegrationTest
  def test_registration    
    # Try to access the account area without being logged in
    get account_url
    assert_redirected_to new_user_session_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "user_sessions/new"
    
    # Try to register with no info
    post users_url
    assert_template "users/new"
    
    # Register successfully
    post users_url, {:user => {:login => "binarylogic", :password => "pass", :confirm_password => "pass", :first_name => "Ben", :last_name => "Johnson"}}
    assert_redirected_to account_url
    assert flash.key?(:notice)
    
    access_account(User.find(2))
  end
  
  def test_login_process
    # Try to access the account area without being logged in
    get account_url
    assert_redirected_to new_user_session_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "user_sessions/new"
    
    login_unsuccessfully
    login_unsuccessfully("bjohnson", "badpassword")
    login_successfully("bjohnson", "benrocks")
    
    # Try to log in again after a successful login
    get new_user_session_url
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    # Try to register after a successful login
    get new_user_url
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    access_account
    logout(new_user_url) # before I tried to register, it stored my location
    
    # Try to access my account again
    get account_url
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
  end
  
  def test_changing_password
    # Try logging in with correct credentials
    login_successfully("bjohnson", "benrocks")
    
    # Go to edit form
    get edit_account_path
    assert_template "users/edit"
    
    # Edit password
    put account_path, :user => {:login => "bjohnson", :password => "sillywilly", :confirm_password => "sillywilly", :first_name => "Ben", :last_name => "Johnson"}
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    access_account
    logout
    
    # Try to access my account again
    get account_url
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
    
    login_successfully("bjohnson", "sillywilly")
    access_account
  end
end