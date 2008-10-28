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
    assert_equal "6cde0674657a8a313ce952df979de2830309aa4c11ca65805dd00bfdc65dbcc2f5e36718660a1d2e68c1a08c276d996763985d2f06fd3d076eb7bc4d97b1e317", session[:user_credentials]
    assert_equal ["6cde0674657a8a313ce952df979de2830309aa4c11ca65805dd00bfdc65dbcc2f5e36718660a1d2e68c1a08c276d996763985d2f06fd3d076eb7bc4d97b1e317"], cookies["user_credentials"]
    assert_redirected_to account_url
  end
  
  def test_unsuccessful_create
    get :create, {:user_session => {:login => "bjohnson", :password => "badpassword"}}
    assert_equal nil, session[:user_credentials]
    assert_equal nil, cookies["user_credentials"]
    assert_template "new"
  end
  
  def test_destroy
    get :destroy
    assert_equal nil, session[:user_credentials]
    assert_equal nil, cookies["user_credentials"]
    assert_redirected_to new_user_session_url
    assert flash.key?(:notice)
  end
end
