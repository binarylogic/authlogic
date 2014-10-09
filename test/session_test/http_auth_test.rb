require 'test_helper'

module SessionTest
  class HttpAuthTest < ActiveSupport::TestCase
    class ConfigTest < ActiveSupport::TestCase
      def test_allow_http_basic_auth
        klass = testable_user_session_class

        klass.allow_http_basic_auth = false
        assert_equal false, klass.allow_http_basic_auth

        klass.allow_http_basic_auth true
        assert_equal true, klass.allow_http_basic_auth
      end

      def test_request_http_basic_auth
        klass = testable_user_session_class

        klass.request_http_basic_auth = true
        assert_equal true, klass.request_http_basic_auth

        klass.request_http_basic_auth = false
        assert_equal false, klass.request_http_basic_auth
      end

      def test_http_basic_auth_realm
        klass = testable_user_session_class

        assert_equal 'Application', klass.http_basic_auth_realm
        assert_equal 'Application', UserSession.http_basic_auth_realm

        klass.http_basic_auth_realm = 'TestRealm'
        assert_equal 'TestRealm', klass.http_basic_auth_realm
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_persist_persist_by_http_auth_with_no_creds
        http_basic_auth_for do
          assert !UserSession.find
        end
      end

      def test_persist_persist_by_http_auth_with_creds
        aaron = users(:aaron)

        http_basic_auth_for(aaron) do
          assert session = UserSession.find
          assert_equal aaron, session.record
          assert_equal aaron.login, session.login
          assert_equal "aaronrocks", session.send(:protected_password)
          assert !controller.http_auth_requested?
        end
      end

      def test_persist_persist_by_http_auth_with_creds_and_custom_realm
        klass = testable_user_session_class
        aaron = users(:aaron)

        klass.request_http_basic_auth = true
        klass.http_basic_auth_realm = 'PersistTestRealm'

        http_basic_auth_for(aaron) do
          assert session = klass.find
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
