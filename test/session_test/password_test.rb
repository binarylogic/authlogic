# frozen_string_literal: true

require "test_helper"

module SessionTest
  module PasswordTest
    class ConfigTest < ActiveSupport::TestCase
      def test_find_by_login_method_is_deprecated
        expected_warning = Regexp.new(
          Regexp.escape(::Authlogic::Session::Base::E_DPR_FIND_BY_LOGIN_METHOD)
        )

        assert_output(nil, expected_warning) do
          UserSession.find_by_login_method = "my_login_method"
        end
        assert_equal "my_login_method", UserSession.record_selection_method

        assert_output(nil, expected_warning) do
          UserSession.find_by_login_method "find_by_login"
        end
        assert_equal "find_by_login", UserSession.record_selection_method
      end

      def test_record_selection_method
        UserSession.record_selection_method = "my_login_method"
        assert_equal "my_login_method", UserSession.record_selection_method

        UserSession.record_selection_method "find_by_login"
        assert_equal "find_by_login", UserSession.record_selection_method
      end

      def test_verify_password_method
        UserSession.verify_password_method = "my_login_method"
        assert_equal "my_login_method", UserSession.verify_password_method

        UserSession.verify_password_method "valid_password?"
        assert_equal "valid_password?", UserSession.verify_password_method
      end

      def test_generalize_credentials_error_mesages_set_to_false
        UserSession.generalize_credentials_error_messages false
        refute UserSession.generalize_credentials_error_messages
        session = UserSession.create(login: users(:ben).login, password: "invalud-password")
        assert_equal ["Password is not valid"], session.errors.full_messages
      end

      def test_generalize_credentials_error_messages_set_to_true
        UserSession.generalize_credentials_error_messages true
        assert UserSession.generalize_credentials_error_messages
        session = UserSession.create(login: users(:ben).login, password: "invalud-password")
        assert_equal ["Login/Password combination is not valid"], session.errors.full_messages
      end

      def test_generalize_credentials_error_messages_set_to_string
        UserSession.generalize_credentials_error_messages = "Custom Error Message"
        assert UserSession.generalize_credentials_error_messages
        session = UserSession.create(login: users(:ben).login, password: "invalud-password")
        assert_equal ["Custom Error Message"], session.errors.full_messages
      end

      def test_login_field
        UserSession.configured_password_methods = false
        UserSession.login_field = :saweet
        assert_equal :saweet, UserSession.login_field
        session = UserSession.new
        assert session.respond_to?(:saweet)

        UserSession.login_field :login
        assert_equal :login, UserSession.login_field
        session = UserSession.new
        assert session.respond_to?(:login)
      end

      def test_password_field
        UserSession.configured_password_methods = false
        UserSession.password_field = :saweet
        assert_equal :saweet, UserSession.password_field
        session = UserSession.new
        assert session.respond_to?(:saweet)

        UserSession.password_field :password
        assert_equal :password, UserSession.password_field
        session = UserSession.new
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
        session.credentials = { login: "login", password: "pass" }
        assert_equal "login", session.login
        assert_nil session.password
        assert_equal "pass", session.send(:protected_password)
        assert_equal({ password: "<protected>", login: "login" }, session.credentials)
      end

      def test_credentials_are_params_safe
        session = UserSession.new
        assert_nothing_raised { session.credentials = { hacker_method: "error!" } }
      end

      def test_save_with_credentials
        aaron = users(:aaron)
        session = UserSession.new(login: aaron.login, password: "aaronrocks")
        assert session.save
        refute session.new_session?
        assert_equal 1, session.record.login_count
        assert Time.now >= session.record.current_login_at
        assert_equal "1.1.1.1", session.record.current_login_ip
        assert_equal env_session_options[:renew], true
      end
    end
  end
end
