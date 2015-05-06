require 'test_helper'

module SessionTest
  module CookiesTest
    class ConfiTest < ActiveSupport::TestCase
      def test_cookie_key
        UserSession.cookie_key = "my_cookie_key"
        assert_equal "my_cookie_key", UserSession.cookie_key

        UserSession.cookie_key "user_credentials"
        assert_equal "user_credentials", UserSession.cookie_key
      end

      def test_default_cookie_key
        assert_equal "user_credentials", UserSession.cookie_key
        assert_equal "back_office_user_credentials", BackOfficeUserSession.cookie_key
      end

      def test_remember_me
        UserSession.remember_me = true
        assert_equal true, UserSession.remember_me
        session = UserSession.new
        assert_equal true, session.remember_me

        UserSession.remember_me false
        assert_equal false, UserSession.remember_me
        session = UserSession.new
        assert_equal false, session.remember_me
      end

      def test_remember_me_for
        UserSession.remember_me_for = 3.years
        assert_equal 3.years, UserSession.remember_me_for
        session = UserSession.new
        session.remember_me = true
        assert_equal 3.years, session.remember_me_for

        UserSession.remember_me_for 3.months
        assert_equal 3.months, UserSession.remember_me_for
        session = UserSession.new
        session.remember_me = true
        assert_equal 3.months, session.remember_me_for
      end

      def test_secure
        UserSession.secure = true
        assert_equal true, UserSession.secure
        session = UserSession.new
        assert_equal true, session.secure

        UserSession.secure false
        assert_equal false, UserSession.secure
        session = UserSession.new
        assert_equal false, session.secure
      end

      def test_httponly
        UserSession.httponly = true
        assert_equal true, UserSession.httponly
        session = UserSession.new
        assert_equal true, session.httponly

        UserSession.httponly false
        assert_equal false, UserSession.httponly
        session = UserSession.new
        assert_equal false, session.httponly
      end

      def test_sign_cookie
        UserSession.sign_cookie = true
        assert_equal true, UserSession.sign_cookie
        session = UserSession.new
        assert_equal true, session.sign_cookie

        UserSession.sign_cookie false
        assert_equal false, UserSession.sign_cookie
        session = UserSession.new
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

      def test_persist_persist_by_cookie_with_blank_persistence_token
        ben = users(:ben)
        ben.update_column(:persistence_token, "")
        assert !UserSession.find
        set_cookie_for(ben)
        assert !UserSession.find
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
