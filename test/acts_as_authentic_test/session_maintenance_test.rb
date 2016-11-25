require 'test_helper'

module ActsAsAuthenticTest
  class SessionMaintenanceTest < ActiveSupport::TestCase
    def test_automatically_log_in_new_users_config
      assert User.automatically_log_in_new_user
      User.automatically_log_in_new_user = false
      refute User.automatically_log_in_new_user
      User.automatically_log_in_new_user true
      assert User.automatically_log_in_new_user
    end

    def test_update_session_with_password_change_config
      assert User.update_session_with_password_change
      User.update_session_with_password_change = false
      refute User.update_session_with_password_change
      User.update_session_with_password_change true
      assert User.update_session_with_password_change
    end

    def test_login_after_create
      # it should autenticate the new user
      User.automatically_log_in_new_user true
      user = User.create(
        :login => "awesome",
        :password => "saweeeet",
        :password_confirmation => "saweeeet",
        :email => "awesome@awesome.com"
      )
      assert user.persisted?
      assert UserSession.find
      logged_in_user = UserSession.find.user
      assert logged_in_user == user

      # it should not autenticate the new user
      User.automatically_log_in_new_user false
      user2 = User.create(
        :login => "awesome2",
        :password => "saweeeet2",
        :password_confirmation => "saweeeet2",
        :email => "awesome2@awesome.com"
      )
      assert user.persisted?
      logged_in_user = UserSession.find.user
      refute logged_in_user == user2
      assert logged_in_user == user
    end

    def test_updating_session_with_failed_magic_state
      ben = users(:ben)
      ben.confirmed = false
      ben.password = "newpasswd"
      ben.password_confirmation = "newpasswd"
      assert ben.save
    end

    def test_update_session_after_password_modify
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
        :login => "awesome",
        :password => "saweet", # Password is too short, user invalid
        :password_confirmation => "saweet",
        :email => "awesome@saweet.com"
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
