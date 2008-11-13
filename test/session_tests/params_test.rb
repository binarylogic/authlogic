require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class ParamsTest < ActiveSupport::TestCase
    def test_valid_params
      ben = users(:ben)
      session = UserSession.new
    
      assert !session.valid_params?
    
      set_params_for(ben)
      assert session.valid_params?
      assert_equal ben, session.unauthorized_record
    end
  end
end