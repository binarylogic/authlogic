require 'test_helper'

module ActsAsAuthenticTest
  class SessionMaintenanceTest < ActiveSupport::TestCase
    def setup
      User.log_in_after_create = true
      User.log_in_after_password_change = true
    end

    def test_log_in_after_create_config
      assert User.log_in_after_create
      User.log_in_after_create = false
      refute User.log_in_after_create
      User.log_in_after_create = true
      assert User.log_in_after_create
    end

    def test_log_in_after_password_change_config
      assert User.log_in_after_password_change
      User.log_in_after_password_change = false
      refute User.log_in_after_password_change
      User.log_in_after_password_change = true
      assert User.log_in_after_password_change
    end

    def test_login_after_create
      User.log_in_after_create = true
      user = User.create(
        login: "awesome",
        password: "saweeeet",
        password_confirmation: "saweeeet",
        email: "awesome@awesome.com"
      )
      assert user.persisted?
      assert UserSession.find
      logged_in_user = UserSession.find.user
      assert_equal logged_in_user, user
    end

    def test_no_login_after_create
      old_user = User.create(
        login: "awesome",
        password: "saweeeet",
        password_confirmation: "saweeeet",
        email: "awesome@awesome.com"
      )
      User.log_in_after_create = false
      user2 = User.create(
        login: "awesome2",
        password: "saweeeet2",
        password_confirmation: "saweeeet2",
        email: "awesome2@awesome.com"
      )
      assert user2.persisted?
      logged_in_user = UserSession.find.user
      assert_not_equal logged_in_user, user2
      assert_equal logged_in_user, old_user
    end

    def test_updating_session_with_failed_magic_state
      ben = users(:ben)
      ben.confirmed = false
      ben.password = "newpasswd"
      ben.password_confirmation = "newpasswd"
      assert ben.save
    end

    def test_update_session_after_password_modify
      User.log_in_after_password_change = true
      ben = users(:ben)
      UserSession.create(ben)
      old_session_key = controller.session["user_credentials"]
      old_cookie_key = controller.cookies["user_credentials"]
      ben.password = "newpasswd"
      ben.password_confirmation = "newpasswd"
      assert ben.save
      assert controller.session["user_credentials"]
      assert controller.cookies["user_credentials"]
      assert_not_equal controller.session["user_credentials"], old_session_key
      assert_not_equal controller.cookies["user_credentials"], old_cookie_key
    end

    def test_no_update_session_after_password_modify
      User.log_in_after_password_change = false
      ben = users(:ben)
      UserSession.create(ben)
      old_session_key = controller.session["user_credentials"]
      old_cookie_key = controller.cookies["user_credentials"]
      ben.password = "newpasswd"
      ben.password_confirmation = "newpasswd"
      assert ben.save
      assert controller.session["user_credentials"]
      assert controller.cookies["user_credentials"]
      assert_equal controller.session["user_credentials"], old_session_key
      assert_equal controller.cookies["user_credentials"], old_cookie_key
    end

    def test_no_session_update_after_modify
      ben = users(:ben)
      UserSession.create(ben)
      old_session_key = controller.session["user_credentials"]
      old_cookie_key = controller.cookies["user_credentials"]
      ben.first_name = "Ben"
      assert ben.save
      assert_equal controller.session["user_credentials"], old_session_key
      assert_equal controller.cookies["user_credentials"], old_cookie_key
    end

    def test_creating_other_user
      ben = users(:ben)
      UserSession.create(ben)
      old_session_key = controller.session["user_credentials"]
      old_cookie_key = controller.cookies["user_credentials"]
      user = User.create(
        login: "awesome",
        password: "saweet", # Password is too short, user invalid
        password_confirmation: "saweet",
        email: "awesome@saweet.com"
      )
      refute user.persisted?
      assert_equal controller.session["user_credentials"], old_session_key
      assert_equal controller.cookies["user_credentials"], old_cookie_key
    end

    def test_updating_other_user
      ben = users(:ben)
      UserSession.create(ben)
      old_session_key = controller.session["user_credentials"]
      old_cookie_key = controller.cookies["user_credentials"]
      zack = users(:zack)
      zack.password = "newpasswd"
      zack.password_confirmation = "newpasswd"
      assert zack.save
      assert_equal controller.session["user_credentials"], old_session_key
      assert_equal controller.cookies["user_credentials"], old_cookie_key
    end

    def test_resetting_password_when_logged_out
      ben = users(:ben)
      refute UserSession.find
      ben.password = "newpasswd"
      ben.password_confirmation = "newpasswd"
      assert ben.save
      assert UserSession.find
      assert_equal ben, UserSession.find.record
    end
  end
end
