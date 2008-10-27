require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    @controller = UserSessionsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_new
    get :new
    assert @controller.instance_variable_get(:@user_session).is_a?(UserSession)
  end
  
  def test_successful_create
    get :create, {:user_session => {:login => "bjohnson", :password => "benrocks"}}
    assert_equal 1, session[:user_id]
    assert_equal ["23a1d7c66f456b14b45211aa656ce8ba7052fd220cd2d07a5c323792938f2a14"], cookies["user_credentials"]
    assert_redirected_to account_url
  end
  
  def test_unsuccessful_create
    get :create, {:user_session => {:login => "bjohnson", :password => "badpassword"}}
    assert_equal nil, session[:user_id]
    assert_equal nil, cookies["user_credentials"]
    assert_template "new"
  end
  
  def test_destroy
    get :destroy
    assert_equal nil, session[:user_id]
    assert_equal nil, cookies["user_credentials"]
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
  end
end
