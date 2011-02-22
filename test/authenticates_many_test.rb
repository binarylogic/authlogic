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
    
    #puts @zack.inspect
    #set_session_for(@zack)
    
    puts @binary_logic.user_sessions.inspect
    assert !@binary_logic.user_sessions.find
    
    #set_session_for(@ben)
    assert @binary_logic.user_sessions.find
  end
end