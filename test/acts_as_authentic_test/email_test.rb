require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class EmailTest < ActiveSupport::TestCase
    def test_email_field_config
      assert_equal :email, User.aaa_config.email_field
      assert_equal :email, Employee.aaa_config.email_field
      
      User.aaa_config.email_field = :nope
      assert_equal :nope, User.aaa_config.email_field
      User.aaa_config.email_field :email
      assert_equal :email, User.aaa_config.email_field
    end
    
    def test_validate_email_field_config
      assert User.aaa_config.validate_email_field
      assert Employee.aaa_config.validate_email_field
      
      User.aaa_config.validate_email_field = false
      assert !User.aaa_config.validate_email_field
      User.aaa_config.validate_email_field true
      assert User.aaa_config.validate_email_field
    end
    
    def test_validates_length_of_email_field_options_config
      assert_equal({:within => 6..100}, User.aaa_config.validates_length_of_email_field_options)
      assert_equal({:within => 6..100}, Employee.aaa_config.validates_length_of_email_field_options)
      
      User.aaa_config.validates_length_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.aaa_config.validates_length_of_email_field_options)
      User.aaa_config.validates_length_of_email_field_options({:within => 6..100})
      assert_equal({:within => 6..100}, User.aaa_config.validates_length_of_email_field_options)
    end
    
    def test_validates_format_of_email_field_options_config
      default = {:with => User.aaa_config.send(:email_regex), :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address.")}
      assert_equal default, User.aaa_config.validates_format_of_email_field_options
      assert_equal default, Employee.aaa_config.validates_format_of_email_field_options
      
      User.aaa_config.validates_format_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.aaa_config.validates_format_of_email_field_options)
      User.aaa_config.validates_format_of_email_field_options default
      assert_equal default, User.aaa_config.validates_format_of_email_field_options
    end
    
    def test_validates_length_of_email_field
      u = User.new
      u.email = "a@a.a"
      assert !u.valid?
      assert u.errors.on(:email)
      
      u.email = "a@a.com"
      assert !u.valid?
      assert !u.errors.on(:email)
    end
    
    def test_validates_format_of_email_field
      u = User.new
      u.email = "aaaaaaaaaaaaa"
      assert !u.valid?
      assert u.errors.on(:email)
      
      u.email = "a@a.com"
      assert !u.valid?
      assert !u.errors.on(:email)
    end
    
    def test_validates_uniqueness_of_email_field
      u = User.new
      u.email = "bjohnson@binarylogic.com"
      assert !u.valid?
      assert u.errors.on(:email)
      
      u.email = "a@a.com"
      assert !u.valid?
      assert !u.errors.on(:email)
    end
  end
end