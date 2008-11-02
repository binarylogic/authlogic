require 'test_helper'

class UserSessionConfigTest < ActionController::IntegrationTest
=begin
  def test_authenticate_with
    UserSession.authenticate_with = Account
    assert_equal Account, UserSession.authenticate_with
    
    UserSession.authenticate_with User
    assert_equal User, UserSession.authenticate_with
  end
  
  def test_login_field
    UserSession.login_field = :email
    assert :email, UserSession.login_field
    
    UserSession.login_field :email2
    assert :email2, UserSession.login_field
    
    UserSession.login_field = :login
    assert :login, UserSession.login_field
  end
=end
end