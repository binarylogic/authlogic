require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class LoginTest < ActiveSupport::TestCase
    def test_login_field_config
      assert_equal :login, User.aaa_config.login_field
      assert_nil Employee.aaa_config.login_field
      
      User.aaa_config.login_field = :nope
      assert_equal :nope, User.aaa_config.login_field
      User.aaa_config.login_field :login
      assert_equal :login, User.aaa_config.login_field
    end
    
    def test_validate_login_field_config
      assert User.aaa_config.validate_login_field
      assert Employee.aaa_config.validate_login_field
      
      User.aaa_config.validate_login_field = false
      assert !User.aaa_config.validate_login_field
      User.aaa_config.validate_login_field true
      assert User.aaa_config.validate_login_field
    end
    
    def test_validates_length_of_login_field_options_config
      assert_equal({:within => 6..100}, User.aaa_config.validates_length_of_login_field_options)
      assert_equal({:within => 6..100}, Employee.aaa_config.validates_length_of_login_field_options)
      
      User.aaa_config.validates_length_of_login_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.aaa_config.validates_length_of_login_field_options)
      User.aaa_config.validates_length_of_login_field_options({:within => 6..100})
      assert_equal({:within => 6..100}, User.aaa_config.validates_length_of_login_field_options)
    end
    
    def test_validates_format_of_login_field_options_config
      default = {:with => /\A\w[\w\.\-_@ ]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please.")}
      assert_equal default, User.aaa_config.validates_format_of_login_field_options
      assert_equal default, Employee.aaa_config.validates_format_of_login_field_options
      
      User.aaa_config.validates_format_of_login_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.aaa_config.validates_format_of_login_field_options)
      User.aaa_config.validates_format_of_login_field_options default
      assert_equal default, User.aaa_config.validates_format_of_login_field_options
    end
    
    def test_validates_length_of_login_field
      u = User.new
      u.login = "a"
      assert !u.valid?
      assert u.errors.on(:login)
      
      u.login = "aaaaaaaaaa"
      assert !u.valid?
      assert !u.errors.on(:login)
    end
    
    def test_validates_format_of_login_field
      u = User.new
      u.login = "fdsf@^&*"
      assert !u.valid?
      assert u.errors.on(:login)
      
      u.login = "fdsfdsfdsfdsfs"
      assert !u.valid?
      assert !u.errors.on(:login)
    end
    
    def test_validates_uniqueness_of_login_field
      u = User.new
      u.login = "bjohnson"
      assert !u.valid?
      assert u.errors.on(:login)
      
      u.login = "fdsfdsf"
      assert !u.valid?
      assert !u.errors.on(:login)
    end
  end
end