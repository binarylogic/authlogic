require 'test_helper'

class AuthenticatesManyTest < ActiveSupport::TestCase
  def test_employee_sessions
    binary_logic = companies(:binary_logic)

    # Drew is a binary_logic employee, authentication succeeds
    drew = employees(:drew)
    set_session_for(drew)
    assert binary_logic.employee_sessions.find

    # Jennifer is not a binary_logic employee, authentication fails
    jennifer = employees(:jennifer)
    set_session_for(jennifer)
    refute binary_logic.employee_sessions.find
  end

  def test_user_sessions
    binary_logic = companies(:binary_logic)

    # Ben is a binary_logic user, authentication succeeds
    ben = users(:ben)
    set_session_for(ben, binary_logic)
    assert binary_logic.user_sessions.find

    # Zack is not a binary_logic user, authentication fails
    zack = users(:zack)
    set_session_for(zack, binary_logic)
    refute binary_logic.user_sessions.find
  end
end
