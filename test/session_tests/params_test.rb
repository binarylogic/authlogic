require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class ParamsTest < ActiveSupport::TestCase
    def test_valid_params
      ben = users(:ben)
      session = UserSession.new
    
      assert !session.valid_params?
      set_params_for(ben)
      
      assert !session.valid_params?
      assert !session.unauthorized_record
      assert !@controller.session["user_credentials"]
      
      set_request_content_type("text/plain")
      assert !session.valid_params?
      assert !session.unauthorized_record
      assert !@controller.session["user_credentials"]
      
      set_request_content_type("application/atom+xml")
      assert session.valid_params?
      assert_equal ben, session.unauthorized_record
      assert !@controller.session["user_credentials"]
      
      set_request_content_type("application/rss+xml")
      assert session.valid_params?
      assert_equal ben, session.unauthorized_record
      assert !@controller.session["user_credentials"]
    end
  end
end