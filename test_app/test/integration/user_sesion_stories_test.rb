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
    post account_url
    assert_template "users/new"
    
    # Register successfully
    post account_url, {:user => {:login => "binarylogic", :password => "pass", :confirm_password => "pass", :first_name => "Ben", :last_name => "Johnson"}}
    assert_redirected_to account_url
    assert flash.key?(:notice)
        
    assert_account_access(User.last)
  end
  
  def test_login_process
    # Try to access the account area without being logged in
    get account_url
    assert_redirected_to new_user_session_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "user_sessions/new"
    
    assert_unsuccessful_login
    assert_unsuccessful_login("bjohnson", "badpassword")
    assert_successful_login("bjohnson", "benrocks")
    
    # Try to log in again after a successful login
    get new_user_session_url
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    # Try to register after a successful login
    get new_account_url
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    assert_account_access
    assert_successful_logout(new_account_url) # before I tried to register, it stored my location
    
    # Try to access my account again
    get account_url
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
  end
  
  def test_changing_password
    # Try logging in with correct credentials
    assert_successful_login("bjohnson", "benrocks")
    
    # Go to edit form
    get edit_account_path
    assert_template "users/edit"
    
    # Edit password
    put account_path, :user => {:login => "bjohnson", :password => "sillywilly", :confirm_password => "sillywilly", :first_name => "Ben", :last_name => "Johnson"}
    assert_redirected_to account_url
    follow_redirect!
    assert flash.key?(:notice)
    assert_template "users/show"
    
    assert_account_access
    assert_successful_logout
    
    # Try to access my account again
    get account_url
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
    
    assert_successful_login("bjohnson", "sillywilly")
    assert_account_access
  end
  
  def test_updating_user_with_no_password_change
    ben = users(:ben)
    profile_views = ben.profile_views
    assert_no_account_access
    get user_url(ben)
    ben.reload
    assert ben.profile_views > profile_views
    assert_no_account_access
  end
  
  def test_updating_user_with_password_change
    ben = users(:ben)
    crypted_password = ben.crypted_password
    assert_no_account_access
    get reset_password_user_url(ben)
    ben.reload
    assert_not_equal crypted_password, ben.crypted_password
    assert_account_access
  end
end