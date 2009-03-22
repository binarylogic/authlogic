require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTest
  class HttpAuthTest < ActiveSupport::TestCase
    def test_persist_persist_by_http_auth
      ben = users(:ben)
      http_basic_auth_for { assert !UserSession.find }
      http_basic_auth_for(ben) do
        assert session = UserSession.find
        assert_equal ben, session.record
        assert_equal ben.login, session.login
        assert_equal "benrocks", session.send(:protected_password)
      end
    end
  end
end