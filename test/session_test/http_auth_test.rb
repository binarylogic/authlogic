require 'test_helper'

module SessionTest
  class HttpAuthTest < ActiveSupport::TestCase
    class ConfiTest < ActiveSupport::TestCase
      def test_allow_http_basic_auth
        UserSession.allow_http_basic_auth = false
        assert_equal false, UserSession.allow_http_basic_auth
    
        UserSession.allow_http_basic_auth true
        assert_equal true, UserSession.allow_http_basic_auth
      end
    end
    
    class InstanceMethodsTest < ActiveSupport::TestCase
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
end