require 'test_helper'

# We forbid the use of AC::Parameters, and we have a test to that effect, but we
# do not want a development dependency on `actionpack`, so we define it here.
module ActionController
  class Parameters; end
end

module SessionTest
  class FoundationTest < ActiveSupport::TestCase
    def test_credentials_raise_if_not_a_hash
      session = UserSession.new
      e = assert_raises(TypeError) {
        session.credentials = ActionController::Parameters.new
      }
      assert_equal(
        ::Authlogic::Session::Foundation::InstanceMethods::E_AC_PARAMETERS,
        e.message
      )
    end
  end
end
