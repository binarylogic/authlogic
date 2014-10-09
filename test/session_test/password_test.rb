require 'test_helper'

module SessionTest
  module PasswordTest
    class ConfigTest < ActiveSupport::TestCase
      def test_find_by_login_method
        klass = testable_user_session_class

        klass.find_by_login_method = "my_login_method"
        assert_equal "my_login_method", klass.find_by_login_method

        klass.find_by_login_method "find_by_login"
        assert_equal "find_by_login", klass.find_by_login_method
      end

      def test_verify_password_method
        klass = testable_user_session_class

        klass.verify_password_method = "my_login_method"
        assert_equal "my_login_method", klass.verify_password_method

        klass.verify_password_method "valid_password?"
        assert_equal "valid_password?", klass.verify_password_method
      end

      def test_generalize_credentials_error_mesages_set_to_false
        klass = testable_user_session_class

        klass.generalize_credentials_error_messages false
        assert !klass.generalize_credentials_error_messages
        session = klass.create(:login => users(:ben).login, :password => "invalud-password")
        assert_equal ["Password is not valid"], session.errors.full_messages
      end

      def test_generalize_credentials_error_messages_set_to_true
        klass = testable_user_session_class

        klass.generalize_credentials_error_messages true
        assert klass.generalize_credentials_error_messages
        session = klass.create(:login => users(:ben).login, :password => "invalud-password")
        assert_equal ["Login/Password combination is not valid"], session.errors.full_messages
      end

      def test_generalize_credentials_error_messages_set_to_string
        klass = testable_user_session_class

        klass.generalize_credentials_error_messages = "Custom Error Message"
        assert klass.generalize_credentials_error_messages
        session = klass.create(:login => users(:ben).login, :password => "invalud-password")
        assert_equal ["Custom Error Message"], session.errors.full_messages
      end


      def test_login_field
        klass = testable_user_session_class

        klass.configured_password_methods = false
        klass.login_field = :saweet

        assert_equal :saweet, klass.login_field
        session = klass.new
        assert session.respond_to?(:saweet)

        klass.login_field :login
        assert_equal :login, klass.login_field
        session = klass.new
        assert session.respond_to?(:login)
      end

      def test_password_field
        klass = testable_user_session_class

        klass.configured_password_methods = false
        klass.password_field = :saweet

        assert_equal :saweet, klass.password_field
        session = klass.new
        assert session.respond_to?(:saweet)

        klass.password_field :password
        assert_equal :password, klass.password_field
        session = klass.new
        assert session.respond_to?(:password)
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_init
        session = UserSession.new
        assert session.respond_to?(:login)
        assert session.respond_to?(:login=)
        assert session.respond_to?(:password)
        assert session.respond_to?(:password=)
        assert session.respond_to?(:protected_password, true)
      end

      def test_credentials
        session = UserSession.new
        session.credentials = {:login => "login", :password => "pass"}
        assert_equal "login", session.login
        assert_nil session.password
        assert_equal "pass", session.send(:protected_password)
        assert_equal({:password => "<protected>", :login => "login"}, session.credentials)
      end

      def test_credentials_are_params_safe
        session = UserSession.new
        assert_nothing_raised { session.credentials = {:hacker_method => "error!"} }
      end

      def test_save_with_credentials
        aaron = users(:aaron)
        session = UserSession.new(:login => aaron.login, :password => "aaronrocks")
        assert session.save
        assert !session.new_session?
        assert_equal 1, session.record.login_count
        assert Time.now >= session.record.current_login_at
        assert_equal "1.1.1.1", session.record.current_login_ip
      end
    end
  end
end
