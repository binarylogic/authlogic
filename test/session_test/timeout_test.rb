require 'test_helper'

module SessionTest
  module TimeoutTest
    class ConfigTest < ActiveSupport::TestCase
      def test_logout_on_timeout
        UserSession.logout_on_timeout = true
        assert UserSession.logout_on_timeout

        UserSession.logout_on_timeout false
        refute UserSession.logout_on_timeout
      end
    end

    class InstanceMethods < ActiveSupport::TestCase
      def test_stale_state
        UserSession.logout_on_timeout = true
        ben = users(:ben)
        ben.last_request_at = 3.years.ago
        ben.save
        set_session_for(ben)

        session = UserSession.new
        assert session.persisting?
        assert session.stale?
        assert_equal ben, session.stale_record
        assert_nil session.record
        assert_nil controller.session["user_credentials_id"]

        set_session_for(ben)

        ben.last_request_at = Time.now
        ben.save

        assert session.persisting?
        refute session.stale?
        assert_nil session.stale_record

        UserSession.logout_on_timeout = false
      end

      def test_should_be_stale_with_expired_remember_date
        UserSession.logout_on_timeout = true
        UserSession.remember_me = true
        UserSession.remember_me_for = 3.months
        ben = users(:ben)
        assert ben.save
        session = UserSession.new(ben)
        assert session.save
        Timecop.freeze(Time.now + 4.month)
        assert session.persisting?
        assert session.stale?
        UserSession.remember_me = false
      end

      def test_should_not_be_stale_with_valid_remember_date
        UserSession.logout_on_timeout = true # Default is 10.minutes
        UserSession.remember_me = true
        UserSession.remember_me_for = 3.months
        ben = users(:ben)
        assert ben.save
        session = UserSession.new(ben)
        assert session.save
        Timecop.freeze(Time.now + 2.months)
        assert session.persisting?
        refute session.stale?
        UserSession.remember_me = false
      end

      def test_successful_login
        UserSession.logout_on_timeout = true
        ben = users(:ben)
        session = UserSession.create(login: ben.login, password: "benrocks")
        refute session.new_session?
        session = UserSession.find
        assert session
        assert_equal ben, session.record
        UserSession.logout_on_timeout = false
      end
    end
  end
end
