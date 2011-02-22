require 'test_helper'

class AuthenticatesManyTest < ActiveSupport::TestCase
  
  def setup
    @zack = users(:zack)
    @ben = users(:ben)
    @binary_logic = companies(:binary_logic)
    
  end
  
  
  def test_warmup
    assert @zack
    assert @ben
    assert @binary_logic
  end
  
  def test_scoping
    
    set_session_for(@zack)
    assert !@binary_logic.user_sessions.find
    
    set_session_for(@ben)
    assert @binary_logic.user_sessions.find
  end
end