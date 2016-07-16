require 'test_helper'

module ActsAsAuthenticTest
  class LoggedInStatusTest < ActiveSupport::TestCase
    ERROR_MSG = 'Multiple calls to %s should result in different relations'

    def test_logged_in_timeout_config
      assert_equal 10.minutes.to_i, User.logged_in_timeout
      assert_equal 10.minutes.to_i, Employee.logged_in_timeout

      User.logged_in_timeout = 1.hour
      assert_equal 1.hour.to_i, User.logged_in_timeout
      User.logged_in_timeout 10.minutes
      assert_equal 10.minutes.to_i, User.logged_in_timeout
    end

    def test_named_scope_logged_in
      # Testing that the scope returned differs, because the time it was called should be
      # slightly different. This is an attempt to make sure the scope is lambda wrapped
      # so that it is re-evaluated every time its called. My biggest concern is that the
      # test happens so fast that the test fails... I just don't know a better way to test it!

      # for rails 5 I've changed the where_values to to_sql to compare

      query1 = User.logged_in.to_sql
      sleep 0.1
      query2 = User.logged_in.to_sql
      assert query1 != query2, ERROR_MSG % '#logged_in'

      assert_equal 0, User.logged_in.count
      user = User.first
      user.last_request_at = Time.now
      user.current_login_at = Time.now
      user.save!
      assert_equal 1, User.logged_in.count
    end

    def test_named_scope_logged_out
      # Testing that the scope returned differs, because the time it was called should be
      # slightly different. This is an attempt to make sure the scope is lambda wrapped
      # so that it is re-evaluated every time its called. My biggest concern is that the
      # test happens so fast that the test fails... I just don't know a better way to test it!

      # for rails 5 I've changed the where_values to to_sql to compare
      
      assert User.logged_in.to_sql != User.logged_out.to_sql, ERROR_MSG % '#logged_out'

      assert_equal 3, User.logged_out.count
      User.first.update_attribute(:last_request_at, Time.now)
      assert_equal 2, User.logged_out.count
    end

    def test_logged_in_logged_out
      u = User.first
      assert !u.logged_in?
      assert u.logged_out?
      u.last_request_at = Time.now
      assert u.logged_in?
      assert !u.logged_out?
    end
  end
end
