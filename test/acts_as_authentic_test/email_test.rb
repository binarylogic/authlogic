require 'test_helper'

module ActsAsAuthenticTest
  class EmailTest < ActiveSupport::TestCase
    def test_email_field_config
      klass = testable_user_class

      assert_equal :email, klass.email_field
      assert_equal :email, User.email_field
      assert_equal :email, Employee.email_field

      klass.email_field = :nope
      assert_equal :nope, klass.email_field
      klass.email_field :email
      assert_equal :email, klass.email_field
    end

    def test_validate_email_field_config
      klass = testable_user_class

      assert klass.validate_email_field
      assert User.validate_email_field
      assert Employee.validate_email_field

      klass.validate_email_field = false
      assert !klass.validate_email_field
      klass.validate_email_field true
      assert klass.validate_email_field
    end

    def test_validates_length_of_email_field_options_config
      klass = testable_user_class

      assert_equal({:maximum => 100}, klass.validates_length_of_email_field_options)
      assert_equal({:maximum => 100}, User.validates_length_of_email_field_options)
      assert_equal({:maximum => 100}, Employee.validates_length_of_email_field_options)

      klass.validates_length_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, klass.validates_length_of_email_field_options)
      klass.validates_length_of_email_field_options({:within => 6..100})
      assert_equal({:within => 6..100}, klass.validates_length_of_email_field_options)
    end

    def test_validates_format_of_email_field_options_config
      klass = testable_user_class

      default = {:with => Authlogic::Regex.email, :message => Proc.new{I18n.t('error_messages.email_invalid', :default => "should look like an email address.")}}
      dmessage = default.delete(:message).call

      options = User.validates_format_of_email_field_options
      message = options.delete(:message)
      assert message.kind_of?(Proc)
      assert_equal dmessage, message.call
      assert_equal default, options

      options = Employee.validates_format_of_email_field_options
      message = options.delete(:message)
      assert message.kind_of?(Proc)
      assert_equal dmessage, message.call
      assert_equal default, options


      klass.validates_format_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, klass.validates_format_of_email_field_options)
      klass.validates_format_of_email_field_options default
      assert_equal default, klass.validates_format_of_email_field_options
    end

    def test_deferred_error_message_translation

      # ensure we successfully loaded the test locale
      assert I18n.available_locales.include?(:lol), "Test locale failed to load"

      original_locale = I18n.locale
      I18n.locale = 'lol'
      message = I18n.t("authlogic.error_messages.email_invalid")

      begin
        cat = User.new
        cat.email = 'meow'
        cat.valid?

        # filter duplicate error messages
        error = cat.errors[:email]
        error = error.first if error.is_a?(Array)

        assert_equal message, error

      ensure
        I18n.locale = original_locale
      end
    end

    def test_validates_uniqueness_of_email_field_options_config
      klass = Class.new(Employee)

      default = {:case_sensitive => false, :scope => Employee.validations_scope, :if => "#{Employee.email_field}_changed?".to_sym}
      assert_equal default, klass.validates_uniqueness_of_email_field_options
      assert_equal default, Employee.validates_uniqueness_of_email_field_options

      klass.validates_uniqueness_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, klass.validates_uniqueness_of_email_field_options)
      klass.validates_uniqueness_of_email_field_options default
      assert_equal default, klass.validates_uniqueness_of_email_field_options
    end

    def test_validates_length_of_email_field
      u = User.new
      u.email = "a@a.a"
      assert !u.valid?
      assert u.errors[:email].size > 0

      u.email = "a@a.com"
      assert !u.valid?
      assert u.errors[:email].size == 0
    end

    def test_validates_format_of_email_field
      u = User.new
      u.email = "aaaaaaaaaaaaa"
      u.valid?
      assert u.errors[:email].size > 0

      u.email = "a@a.com"
      u.valid?
      assert u.errors[:email].size == 0

      u.email = "damien+test1...etc..@mydomain.com"
      u.valid?
      assert u.errors[:email].size == 0

      u.email = "dakota.dux+1@gmail.com"
      u.valid?
      assert u.errors[:email].size == 0

      u.email = "dakota.d'ux@gmail.com"
      u.valid?
      assert u.errors[:email].size == 0

      u.email = "<script>alert(123);</script>\nnobody@example.com"
      assert !u.valid?
      assert u.errors[:email].size > 0
    end

    def test_validates_uniqueness_of_email_field
      u = User.new
      u.email = "bjohnson@binarylogic.com"
      assert !u.valid?
      assert u.errors[:email].size > 0

      u.email = "BJOHNSON@binarylogic.com"
      assert !u.valid?
      assert u.errors[:email].size > 0

      u.email = "a@a.com"
      assert !u.valid?
      assert u.errors[:email].size == 0
    end
  end
end
