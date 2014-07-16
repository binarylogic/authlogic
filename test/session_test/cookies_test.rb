require 'test_helper'

module SessionTest
  module CookiesTest
    class ConfigTest < ActiveSupport::TestCase
      def test_cookie_key
        klass = testable_user_session_class

        klass.cookie_key = "my_cookie_key"
        assert_equal "my_cookie_key", klass.cookie_key

        klass.cookie_key "user_credentials"
        assert_equal "user_credentials", klass.cookie_key
      end

      def test_default_cookie_key
        klass = testable_user_session_class

        assert_equal "user_credentials", klass.cookie_key
        assert_equal "user_credentials", UserSession.cookie_key
        assert_equal "back_office_user_credentials", BackOfficeUserSession.cookie_key
      end

      def test_remember_me
        klass = testable_user_session_class

        klass.remember_me = true
        assert_equal true, klass.remember_me
        session = klass.new
        assert_equal true, session.remember_me

        klass.remember_me false
        assert_equal false, klass.remember_me
        session = klass.new
        assert_equal false, session.remember_me
      end

      def test_remember_me_for
        klass = testable_user_session_class

        klass.remember_me_for = 3.years
        assert_equal 3.years, klass.remember_me_for
        session = klass.new
        session.remember_me = true
        assert_equal 3.years, session.remember_me_for

        klass.remember_me_for 3.months
        assert_equal 3.months, klass.remember_me_for
        session = klass.new
        session.remember_me = true
        assert_equal 3.months, session.remember_me_for
      end

      def test_secure
        klass = testable_user_session_class

        klass.secure = true
        assert_equal true, klass.secure
        session = klass.new
        assert_equal true, session.secure

        klass.secure false
        assert_equal false, klass.secure
        session = klass.new
        assert_equal false, session.secure
      end

      def test_httponly
        klass = testable_user_session_class

        klass.httponly = true
        assert_equal true, klass.httponly
        session = klass.new
        assert_equal true, session.httponly

        klass.httponly false
        assert_equal false, klass.httponly
        session = klass.new
        assert_equal false, session.httponly
      end

      def test_sign_cookie
        klass = testable_user_session_class

        klass.sign_cookie = true
        assert_equal true, klass.sign_cookie
        session = klass.new
        assert_equal true, session.sign_cookie

        klass.sign_cookie false
        assert_equal false, klass.sign_cookie
        session = klass.new
        assert_equal false, session.sign_cookie
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_credentials
        session = UserSession.new
        session.credentials = {:remember_me => true}
        assert_equal true, session.remember_me
      end

      def test_remember_me
        session = UserSession.new
        assert_equal false, session.remember_me
        assert !session.remember_me?

        session.remember_me = false
        assert_equal false, session.remember_me
        assert !session.remember_me?

        session.remember_me = true
        assert_equal true, session.remember_me
        assert session.remember_me?

        session.remember_me = nil
        assert_nil session.remember_me
        assert !session.remember_me?

        session.remember_me = "1"
        assert_equal "1", session.remember_me
        assert session.remember_me?

        session.remember_me = "true"
        assert_equal "true", session.remember_me
        assert session.remember_me?
      end

      def test_remember_me_until
        session = UserSession.new
        assert_nil session.remember_me_until

        session.remember_me = true
        assert 3.months.from_now <= session.remember_me_until
      end

      def test_persist_persist_by_cookie
        ben = users(:ben)
        assert !UserSession.find
        set_cookie_for(ben)
        assert session = UserSession.find
        assert_equal ben, session.record
      end

      def test_remember_me_expired
        ben = users(:ben)
        session = UserSession.new(ben)
        session.remember_me = true
        assert session.save
        assert !session.remember_me_expired?

        session = UserSession.new(ben)
        session.remember_me = false
        assert session.save
        assert !session.remember_me_expired?
      end

      def test_after_save_save_cookie
        ben = users(:ben)
        session = UserSession.new(ben)
        assert session.save
        assert_equal "#{ben.persistence_token}::#{ben.id}", controller.cookies["user_credentials"]
      end

      def test_after_save_save_cookie_signed
        ben = users(:ben)

        assert_nil controller.cookies["user_credentials"]
        payload = "#{ben.persistence_token}::#{ben.id}"

        session = UserSession.new(ben)
        session.sign_cookie = true
        assert session.save
        assert_equal payload, controller.cookies.signed["user_credentials"]
        assert_equal "#{payload}--#{Digest::SHA1.hexdigest payload}", controller.cookies.signed.parent_jar["user_credentials"]
      end

      def test_after_save_save_cookie_with_remember_me
        ben = users(:ben)
        session = UserSession.new(ben)
        session.remember_me = true
        assert session.save
        assert_equal "#{ben.persistence_token}::#{ben.id}::#{session.remember_me_until.iso8601}", controller.cookies["user_credentials"]
      end

      def test_after_destroy_destroy_cookie
        ben = users(:ben)
        set_cookie_for(ben)
        session = UserSession.find
        assert controller.cookies["user_credentials"]
        assert session.destroy
        assert !controller.cookies["user_credentials"]
      end
    end
  end
end
