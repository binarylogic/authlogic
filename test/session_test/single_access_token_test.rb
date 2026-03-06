# frozen_string_literal: true

require "test_helper"

module SessionTest
  module SingleAccessTokenTest
    class ConfigTest < ActiveSupport::TestCase
      def test_params_key
        assert_equal UserSession.cookie_key, UserSession.params_key

        UserSession.params_key = "my_params_key"
        assert_equal "my_params_key", UserSession.params_key

        UserSession.params_key "user_credentials"
        assert_equal "user_credentials", UserSession.params_key
      end

      def test_headers_key
        assert_equal nil, UserSession.headers_key

        UserSession.headers_key = "my_headers_key"
        assert_equal "my_headers_key", UserSession.headers_key

        UserSession.headers_key "user_credentials"
        assert_equal "user_credentials", UserSession.headers_key
      end

      def test_single_access_allowed_request_types
        UserSession.single_access_allowed_request_types = ["my request type"]
        assert_equal ["my request type"], UserSession.single_access_allowed_request_types
        UserSession.single_access_allowed_request_types(
          ["application/rss+xml", "application/atom+xml"]
        )
        assert_equal(
          ["application/rss+xml", "application/atom+xml"],
          UserSession.single_access_allowed_request_types
        )
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_persist_persist_by_params
        assert_persist_by(:params)
      end

      def test_persist_persist_by_headers
        # Since default headers_key is nil, set for the test.
        UserSession.send("headers_key=", "user_credentials")
        assert_persist_by(:headers)
      end

      def assert_persist_by(headers_or_params)
        ben = users(:ben)
        session = UserSession.new

        refute session.persisting?
        send("set_#{headers_or_params}_for", ben)

        refute session.persisting?
        refute session.unauthorized_record
        refute session.record
        assert_nil controller.session["user_credentials"]

        set_request_content_type("text/plain")
        refute session.persisting?
        refute session.unauthorized_record
        assert_nil controller.session["user_credentials"]

        set_request_content_type("application/atom+xml")
        assert session.persisting?
        assert_equal ben, session.record

        # should not persist since this is single access
        assert_nil controller.session["user_credentials"]

        set_request_content_type("application/rss+xml")
        assert session.persisting?
        assert_equal ben, session.unauthorized_record
        assert_nil controller.session["user_credentials"]
      end
    end
  end
end
