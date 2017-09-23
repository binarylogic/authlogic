require 'test_helper'

class AuthenticatesManyTest < ActiveSupport::TestCase
  def set_company_specific_session_for(company, user)
    id = company.id
    controller.session["company_#{id}_user_credentials"] = user.persistence_token
    controller.session["company_#{id}_user_credentials_id"] = user.id
  end

  def test_scoping
    zack = users(:zack)
    ben = users(:ben)
    binary_logic = companies(:binary_logic)
    set_company_specific_session_for(binary_logic, zack)

    refute binary_logic.user_sessions.find

    set_company_specific_session_for(binary_logic, ben)

    assert binary_logic.user_sessions.find
  end
end
