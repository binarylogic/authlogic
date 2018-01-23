require 'test_helper'

module ActsAsAuthenticTest
  class PersistenceTokenTest < ActiveSupport::TestCase
    def test_after_password_set_reset_persistence_token
      ben = users(:ben)
      old_persistence_token = ben.persistence_token
      ben.password = "newpass"
      assert_not_equal old_persistence_token, ben.persistence_token
    end

    def test_after_password_verification_reset_persistence_token
      aaron = users(:aaron)
      old_persistence_token = aaron.persistence_token

      assert aaron.valid_password?(password_for(aaron))
      assert_equal old_persistence_token, aaron.reload.persistence_token

      # only update it if it is nil
      assert aaron.update_attribute(:persistence_token, nil)
      assert aaron.valid_password?(password_for(aaron))
      assert_not_equal old_persistence_token, aaron.persistence_token
    end

    def test_before_validate_reset_persistence_token
      u = User.new
      refute u.valid?
      assert_not_nil u.persistence_token
    end

    def test_forget_all
      UserSession.allow_http_basic_auth = true

      http_basic_auth_for(users(:ben)) { UserSession.find }
      http_basic_auth_for(users(:zack)) { UserSession.find(:ziggity_zack) }
      assert UserSession.find
      assert UserSession.find(:ziggity_zack)
      User.forget_all
      refute UserSession.find
      refute UserSession.find(:ziggity_zack)
    end

    def test_forget
      UserSession.allow_http_basic_auth = true

      ben = users(:ben)
      zack = users(:zack)
      http_basic_auth_for(ben) { UserSession.find }
      http_basic_auth_for(zack) { UserSession.find(:ziggity_zack) }

      assert ben.reload.logged_in?
      assert zack.reload.logged_in?

      ben.forget!

      refute UserSession.find
      assert UserSession.find(:ziggity_zack)
    end
  end
end
