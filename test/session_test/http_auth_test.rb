require 'test_helper'

module SessionTest
  class HttpAuthTest < ActiveSupport::TestCase
    class ConfigTest < ActiveSupport::TestCase
      def test_allow_http_basic_auth
        UserSession.allow_http_basic_auth = false
        assert_equal false, UserSession.allow_http_basic_auth

        UserSession.allow_http_basic_auth true
        assert_equal true, UserSession.allow_http_basic_auth
      end

      def test_request_http_basic_auth
        UserSession.request_http_basic_auth = true
        assert_equal true, UserSession.request_http_basic_auth

        UserSession.request_http_basic_auth = false
        assert_equal false, UserSession.request_http_basic_auth
      end

      def test_http_basic_auth_realm
        assert_equal 'Application', UserSession.http_basic_auth_realm
        UserSession.http_basic_auth_realm = 'TestRealm'
        assert_equal 'TestRealm', UserSession.http_basic_auth_realm
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_persist_persist_by_http_auth
        UserSession.allow_http_basic_auth = true

        aaron = users(:aaron)
        http_basic_auth_for do
          refute UserSession.find
        end
        http_basic_auth_for(aaron) do
          assert session = UserSession.find
          assert_equal aaron, session.record
          assert_equal aaron.login, session.login
          assert_equal "aaronrocks", session.send(:protected_password)
          refute controller.http_auth_requested?
        end
        unset_session
        UserSession.request_http_basic_auth = true
        UserSession.http_basic_auth_realm = 'PersistTestRealm'
        http_basic_auth_for(aaron) do
          assert session = UserSession.find
          assert_equal aaron, session.record
          assert_equal aaron.login, session.login
          assert_equal "aaronrocks", session.send(:protected_password)
          assert_equal 'PersistTestRealm', controller.realm
          assert controller.http_auth_requested?
        end
      end
    end
  end
end
