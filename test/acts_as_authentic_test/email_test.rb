# encoding: utf-8
require 'test_helper'

module ActsAsAuthenticTest
  class EmailTest < ActiveSupport::TestCase

    GOOD_ASCII_EMAILS = [
      "a@a.com",
      "damien+test1...etc..@mydomain.com",
      "dakota.dux+1@gmail.com",
      "dakota.d'ux@gmail.com",
      "a&b@c.com",
    ]

    BAD_ASCII_EMAILS = [
      "",
      "aaaaaaaaaaaaa",
      "question?mark@gmail.com",
      "backslash@g\\mail.com",
      "<script>alert(123);</script>\nnobody@example.com",
    ]

    # http://en.wikipedia.org/wiki/ISO/IEC_8859-1#Codepage_layout
    GOOD_ISO88591_EMAILS = [
      "töm.öm@dömain.fi",  # https://github.com/binarylogic/authlogic/issues/176
      "Pelé@examplé.com",  # http://en.wikipedia.org/wiki/Email_address#Internationalization_examples
    ]

    BAD_ISO88591_EMAILS = [
      "",
      "öm(@ava.fi",      # L paren
      "é)@domain.com",   # R paren
      "é[@example.com",  # L bracket
      "question?mark@gmail.com",  # question mark
      "back\\slash@gmail.com",    # backslash
    ]

    GOOD_UTF8_EMAILS = [
      "δκιμή@παράδεγμα.δοκμή",            # http://en.wikipedia.org/wiki/Email_address#Internationalization_examples
      "我本@屋企.香港",                     # http://en.wikipedia.org/wiki/Email_address#Internationalization_examples
      "甲斐@黒川.日買",                     # http://en.wikipedia.org/wiki/Email_address#Internationalization_examples
      "чебурша@ящик-с-пельнами.рф",       # Contains dashes in domain head
      "企斐@黒川.みんな",                                              #  https://github.com/binarylogic/authlogic/issues/176#issuecomment-55829320
    ]

    BAD_UTF8_EMAILS = [
      "",
              ".みんな",                                                    #  https://github.com/binarylogic/authlogic/issues/176#issuecomment-55829320
      'δκιμή@παράδεγμα.δ',          # short TLD
      "öm(@ava.fi",                 # L paren
      "é)@domain.com",              # R paren
      "é[@example.com",             # L bracket
      "δ]@πράιγμα.δοκμή",           # R bracket
      "我\.香港",                    # slash
      "甲;.日本",                    # semicolon
      "ч:@ящик-с-пельнами.рф",      # colon
      "斐,.みんな",                                           #  comma
      "香<.香港",                    # less than
      "我>.香港",                    # greater than
      "我?本@屋企.香港",              # question mark
      "чебурша@ьн\\ами.рф",         # backslash
      "user@domain.com%0A<script>alert('hello')</script>",
    ]

    def test_email_field_config
      assert_equal :email, User.email_field
      assert_equal :email, Employee.email_field

      User.email_field = :nope
      assert_equal :nope, User.email_field
      User.email_field :email
      assert_equal :email, User.email_field
    end

    def test_validate_email_field_config
      assert User.validate_email_field
      assert Employee.validate_email_field

      User.validate_email_field = false
      assert !User.validate_email_field
      User.validate_email_field true
      assert User.validate_email_field
    end

    def test_validates_length_of_email_field_options_config
      assert_equal({:maximum => 100}, User.validates_length_of_email_field_options)
      assert_equal({:maximum => 100}, Employee.validates_length_of_email_field_options)

      User.validates_length_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.validates_length_of_email_field_options)
      User.validates_length_of_email_field_options({:within => 6..100})
      assert_equal({:within => 6..100}, User.validates_length_of_email_field_options)
    end

    def test_validates_format_of_email_field_options_config
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


      User.validates_format_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, User.validates_format_of_email_field_options)
      User.validates_format_of_email_field_options default
      assert_equal default, User.validates_format_of_email_field_options

      with_email_nonascii = {:with => Authlogic::Regex.email_nonascii, :message => Proc.new{I18n.t('error_messages.email_invalid_international', :default => "should look like an international email address.")}}
      User.validates_format_of_email_field_options = with_email_nonascii
      assert_equal(with_email_nonascii, User.validates_format_of_email_field_options)
      User.validates_format_of_email_field_options with_email_nonascii
      assert_equal with_email_nonascii, User.validates_format_of_email_field_options
    end

    def test_deferred_error_message_translation
      # ensure we successfully loaded the test locale
      assert I18n.available_locales.include?(:lol), "Test locale failed to load"

      I18n.with_locale('lol') do
        message = I18n.t("authlogic.error_messages.email_invalid")

        cat = User.new
        cat.email = 'meow'
        cat.valid?

        # filter duplicate error messages
        error = cat.errors[:email]
        error = error.first if error.is_a?(Array)

        assert_equal message, error
      end
    end

    def test_validates_uniqueness_of_email_field_options_config
      default = {:case_sensitive => false, :scope => Employee.validations_scope, :if => "#{Employee.email_field}_changed?".to_sym}
      assert_equal default, Employee.validates_uniqueness_of_email_field_options

      Employee.validates_uniqueness_of_email_field_options = {:yes => "no"}
      assert_equal({:yes => "no"}, Employee.validates_uniqueness_of_email_field_options)
      Employee.validates_uniqueness_of_email_field_options default
      assert_equal default, Employee.validates_uniqueness_of_email_field_options
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

      u.email = "a&b@c.com"
      u.valid?
      assert u.errors[:email].size == 0
    end

    def test_validates_format_of_nonascii_email_field

      (GOOD_ASCII_EMAILS + GOOD_ISO88591_EMAILS + GOOD_UTF8_EMAILS).each do |e|
        assert e =~  Authlogic::Regex.email_nonascii, "Good email should validate: #{e}"
      end

      (BAD_ASCII_EMAILS + BAD_ISO88591_EMAILS + BAD_UTF8_EMAILS).each do |e|
        assert e !~  Authlogic::Regex.email_nonascii, "Bad email should not validate: #{e}"
      end

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
