require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    @controller = UserSessionsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_truth
    get :create, {:user_session => {:login => "bjohnson", :password => "benrocks"}}
    assert_equal 1, session[:user_id]
    assert_equal ["YmpvaG5zb24=\n:::2e8884187c71ff39af9ac05ebcaa0f40ab2432de51035aff8b0f491f890314d0"], cookies["user_credentials"]
  end
end
