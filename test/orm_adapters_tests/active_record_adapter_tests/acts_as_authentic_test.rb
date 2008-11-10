require File.dirname(__FILE__) + '/../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    class ActsAsAuthenticTest < ActiveSupport::TestCase
      def test_user_validations
        user = User.new
        assert !user.valid?
        assert user.errors.on(:login)
        assert user.errors.on(:password)
    
        user.login = "a"
        assert !user.valid?
        assert user.errors.on(:login)
        assert user.errors.on(:password)
    
        user.login = "%ben*"
        assert !user.valid?
        assert user.errors.on(:login)
        assert user.errors.on(:password)
    
        user.login = "bjohnson"
        assert !user.valid?
        assert user.errors.on(:login)
        assert user.errors.on(:password)
    
        user.login = "my login"
        assert !user.valid?
        assert !user.errors.on(:login)
        assert user.errors.on(:password)
    
        user.password = "my pass"
        assert !user.valid?
        assert !user.errors.on(:password)
        assert user.errors.on(:confirm_password)
    
        user.confirm_password = "my pizass"
        assert !user.valid?
        assert !user.errors.on(:password)
        assert user.errors.on(:confirm_password)
    
        user.confirm_password = "my pass"
        assert user.valid?
      end
  
      def test_employee_validations
        employee = Employee.new
        employee.password = "pass"
        employee.confirm_password = "pass"
    
        assert !employee.valid?
        assert employee.errors.on(:email)
    
        employee.email = "fdsf"
        assert !employee.valid?
        assert employee.errors.on(:email)
    
        employee.email = "fake@email.fake"
        assert !employee.valid?
        assert employee.errors.on(:email)
    
        employee.email = "notfake@email.com"
        assert employee.valid?
      end
  
      def test_named_scopes
        assert_equal 0, User.logged_in.count
        assert_equal User.count, User.logged_out.count
        http_basic_auth_for(users(:ben)) { UserSession.find }
        assert_equal 1, User.logged_in.count
        assert_equal User.count - 1, User.logged_out.count
      end
  
      def test_unique_token
        assert_equal 128, User.unique_token.length
        assert_equal 128, Employee.unique_token.length # make sure encryptions use hashes also
    
        unique_tokens = []
        1000.times { unique_tokens << User.unique_token }
        unique_tokens.uniq!
    
        assert_equal 1000, unique_tokens.size
      end
  
      def test_crypto_provider
        assert_equal Authlogic::CryptoProviders::Sha512, User.crypto_provider
        assert_equal AES128CryptoProvider, Employee.crypto_provider
      end
  
      def test_forget_all
        http_basic_auth_for(users(:ben)) { UserSession.find }
        http_basic_auth_for(users(:zack)) { UserSession.find(:ziggity_zack) }
        assert UserSession.find
        assert UserSession.find(:ziggity_zack)
        User.forget_all!
        assert !UserSession.find
        assert !UserSession.find(:ziggity_zack)
      end
  
      def test_logged_in
        ben = users(:ben)
        assert !ben.logged_in?
        http_basic_auth_for(ben) { UserSession.find }
        assert ben.reload.logged_in?
      end
  
      def test_password
        user = User.new
        user.password = "sillywilly"
        assert user.crypted_password
        assert user.password_salt
        assert user.remember_token
        assert_equal true, user.tried_to_set_password
        assert_nil user.password
    
        employee = Employee.new
        employee.password = "awesome"
        assert employee.crypted_password
        assert employee.remember_token
        assert_equal true, employee.tried_to_set_password
        assert_nil employee.password
      end
  
      def test_valid_password
        ben = users(:ben)
        assert ben.valid_password?("benrocks")
        assert ben.valid_password?(ben.crypted_password)
    
        drew = employees(:drew)
        assert drew.valid_password?("drewrocks")
        assert drew.valid_password?(drew.crypted_password)
      end
  
      def test_forget
        ben = users(:ben)
        zack = users(:zack)
        http_basic_auth_for(ben) { UserSession.find }
        http_basic_auth_for(zack) { UserSession.find(:ziggity_zack) }
    
        assert ben.reload.logged_in?
        assert zack.reload.logged_in?
    
        ben.forget!
    
        assert !UserSession.find
        assert UserSession.find(:ziggity_zack)
      end
  
      def test_reset_password
        ben = users(:ben)
        UserSession.create(ben)
        old_password = ben.crypted_password
        old_salt = ben.password_salt
        old_remember_token = ben.remember_token
        ben.reset_password!
        ben.reload
        assert_not_equal old_password, ben.crypted_password
        assert_not_equal old_salt, ben.password_salt
        assert_not_equal old_remember_token, ben.remember_token
        assert !UserSession.find
      end
  
      def test_login_after_create
        assert User.create(:login => "awesome", :password => "saweet", :confirm_password => "saweet")
        assert UserSession.find
      end
  
      def test_update_session_after_password_modify
        ben = users(:ben)
        UserSession.create(ben)
        old_session_key = @controller.session["user_credentials"]
        old_cookie_key = @controller.cookies["user_credentials"]
        ben.password = "newpass"
        ben.confirm_password = "newpass"
        ben.save
        assert @controller.session["user_credentials"]
        assert @controller.cookies["user_credentials"]
        assert_not_equal @controller.session["user_credentials"], old_session_key
        assert_not_equal @controller.cookies["user_credentials"], old_cookie_key
      end
  
      def test_no_session_update_after_modify
        ben = users(:ben)
        UserSession.create(ben)
        old_session_key = @controller.session["user_credentials"]
        old_cookie_key = @controller.cookies["user_credentials"]
        ben.first_name = "Ben"
        ben.save
        assert_equal @controller.session["user_credentials"], old_session_key
        assert_equal @controller.cookies["user_credentials"], old_cookie_key
      end
  
      def test_updating_other_user
        ben = users(:ben)
        UserSession.create(ben)
        old_session_key = @controller.session["user_credentials"]
        old_cookie_key = @controller.cookies["user_credentials"]
        zack = users(:zack)
        zack.password = "newpass"
        zack.confirm_password = "newpass"
        zack.save
        assert_equal @controller.session["user_credentials"], old_session_key
        assert_equal @controller.cookies["user_credentials"], old_cookie_key
      end
  
      def test_resetting_password_when_logged_out
        ben = users(:ben)
        assert !UserSession.find
        ben.password = "newpass"
        ben.confirm_password = "newpass"
        ben.save
        assert UserSession.find
        assert_equal ben, UserSession.find.record
      end
    end
  end
end