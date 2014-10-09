require 'test_helper'

module SessionTest
  module BruteForceProtectionTest
    class ConfigTest < ActiveSupport::TestCase
      def test_consecutive_failed_logins_limit
        klass = testable_user_session_class

        klass.consecutive_failed_logins_limit = 10
        assert_equal 10, klass.consecutive_failed_logins_limit

        klass.consecutive_failed_logins_limit 50
        assert_equal 50, klass.consecutive_failed_logins_limit
      end

      def test_failed_login_ban_for
        klass = testable_user_session_class

        klass.failed_login_ban_for = 10
        assert_equal 10, klass.failed_login_ban_for

        klass.failed_login_ban_for 2.hours
        assert_equal 2.hours.to_i, klass.failed_login_ban_for
      end
    end
    
    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_under_limit
        ben = users(:ben)
        ben.failed_login_count = UserSession.consecutive_failed_logins_limit - 1
        assert ben.save
        assert UserSession.create(:login => ben.login, :password => "benrocks")
      end

      def test_exceeded_limit
        ben = users(:ben)
        ben.failed_login_count = UserSession.consecutive_failed_logins_limit
        assert ben.save
        assert UserSession.create(:login => ben.login, :password => "benrocks").new_session?
        assert UserSession.create(ben).new_session?

        ben.reload
        ben.updated_at = (UserSession.failed_login_ban_for + 2.hours.to_i).seconds.ago
        assert !UserSession.create(ben).new_session?
      end

      def test_exceeding_failed_logins_limit
        klass = testable_user_session_class
        klass.consecutive_failed_logins_limit = 2

        ben = users(:ben)

        2.times do |i|
          session = klass.new(:login => ben.login, :password => "badpassword1")
          assert !session.save
          assert session.errors[:password].size > 0
          assert_equal i + 1, ben.reload.failed_login_count
        end

        session = klass.new(:login => ben.login, :password => "badpassword2")
        assert !session.save
        assert session.errors[:password].size == 0
        assert_equal 3, ben.reload.failed_login_count
      end

      def test_exceeded_ban_for
        klass = testable_user_session_class
        klass.consecutive_failed_logins_limit = 2
        klass.generalize_credentials_error_messages true

        ben = users(:ben)

        2.times do |i|
          session = klass.new(:login => ben.login, :password => "badpassword1")
          assert !session.save
          assert session.invalid_password?
          assert_equal i + 1, ben.reload.failed_login_count
        end

        ActiveRecord::Base.connection.execute("update users set updated_at = '#{1.day.ago.to_s(:db)}' where login = '#{ben.login}'")
        session = klass.new(:login => ben.login, :password => "benrocks")
        assert session.save
        assert_equal 0, ben.reload.failed_login_count
      end

      def test_exceeded_ban_and_failed_doesnt_ban_again
        klass = testable_user_session_class
        klass.consecutive_failed_logins_limit = 2

        ben = users(:ben)

        2.times do |i|
          session = klass.new(:login => ben.login, :password => "badpassword1")
          assert !session.save
          assert session.errors[:password].size > 0
          assert_equal i + 1, ben.reload.failed_login_count
        end

        ActiveRecord::Base.connection.execute("update users set updated_at = '#{1.day.ago.to_s(:db)}' where login = '#{ben.login}'")
        session = klass.new(:login => ben.login, :password => "badpassword1")
        assert !session.save
        assert_equal 1, ben.reload.failed_login_count
      end
    end
  end
end
