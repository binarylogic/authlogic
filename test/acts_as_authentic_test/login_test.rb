require 'test_helper'

module ActsAsAuthenticTest
  # Tests for configuration option: `validates_format_of_login_field_options`
  class ValidatesFormatOfLoginTest < ActiveSupport::TestCase
    def test_invalid_format
      [
        "fdsf@^&*",
        " space",
        ".dot",
        "-hyphen",
        "@atmark",
        "+plus"
      ].each do |login|
        u = User.new(login: login)
        refute u.valid?
        refute u.errors[:login].empty?
      end
    end

    def test_valid_format
      [
        "fdsfdsfdsfdsfs",
        "dakota.dux+1@gmail.com",
        "marks .-_@+",
        "_underscore"
      ].each do |login|
        u = User.new(login: login)
        refute u.valid?
        assert u.errors[:login].empty?
      end
    end

    def test_validates_format_of_login_field_options_config
      default = {
        with: /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/,
        message: proc do
          I18n.t(
            'error_messages.login_invalid',
            default: "should use only letters, numbers, spaces, and .-_@+ please."
          )
        end
      }
      default_message = default.delete(:message).call

      options = User.validates_format_of_login_field_options
      message = options.delete(:message)
      assert message.is_a?(Proc)
      assert_equal default_message, message.call
      assert_equal default, options

      options = Employee.validates_format_of_login_field_options
      message = options.delete(:message)
      assert message.is_a?(Proc)
      assert_equal default_message, message.call
      assert_equal default, options

      User.validates_format_of_login_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_format_of_login_field_options)
      User.validates_format_of_login_field_options default
      assert_equal default, User.validates_format_of_login_field_options
    end
  end

  # Miscellaneous tests for configuration options related to the `login_field`.
  # Feel free to organize these into separate `TestCase`s as we have done above
  # with `ValidatesFormatOfLoginTest`.
  class MiscellaneousLoginTest < ActiveSupport::TestCase
    def test_login_field_config
      assert_equal :login, User.login_field
      assert_nil Employee.login_field

      User.login_field = :nope
      assert_equal :nope, User.login_field
      User.login_field :login
      assert_equal :login, User.login_field
    end

    def test_validate_login_field_config
      assert User.validate_login_field
      assert Employee.validate_login_field

      User.validate_login_field = false
      refute User.validate_login_field
      User.validate_login_field true
      assert User.validate_login_field
    end

    def test_validates_length_of_login_field_options_config
      assert_equal({ within: 3..100 }, User.validates_length_of_login_field_options)
      assert_equal({ within: 3..100 }, Employee.validates_length_of_login_field_options)

      User.validates_length_of_login_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_length_of_login_field_options)
      User.validates_length_of_login_field_options(within: 3..100)
      assert_equal({ within: 3..100 }, User.validates_length_of_login_field_options)
    end

    def test_validates_uniqueness_of_login_field_options_config
      default = {
        case_sensitive: false,
        scope: User.validations_scope,
        if: "#{User.login_field}_changed?".to_sym
      }
      assert_equal default, User.validates_uniqueness_of_login_field_options

      User.validates_uniqueness_of_login_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_uniqueness_of_login_field_options)
      User.validates_uniqueness_of_login_field_options default
      assert_equal default, User.validates_uniqueness_of_login_field_options
    end

    def test_validates_length_of_login_field
      u = User.new
      u.login = "a"
      refute u.valid?
      refute u.errors[:login].empty?

      u.login = "aaaaaaaaaa"
      refute u.valid?
      assert u.errors[:login].empty?
    end

    def test_validates_uniqueness_of_login_field
      u = User.new
      u.login = "bjohnson"
      refute u.valid?
      refute u.errors[:login].empty?

      u.login = "BJOHNSON"
      refute u.valid?
      refute u.errors[:login].empty?

      u.login = "fdsfdsf"
      refute u.valid?
      assert u.errors[:login].empty?
    end

    def test_find_by_smart_case_login_field
      ben = users(:ben)
      assert_equal ben, User.find_by_smart_case_login_field("bjohnson")
      assert_equal ben, User.find_by_smart_case_login_field("BJOHNSON")
      assert_equal ben, User.find_by_smart_case_login_field("Bjohnson")

      drew = employees(:drew)
      assert_equal drew, Employee.find_by_smart_case_login_field("dgainor@binarylogic.com")
      assert_equal drew, Employee.find_by_smart_case_login_field("Dgainor@binarylogic.com")
      assert_equal drew, Employee.find_by_smart_case_login_field("DGAINOR@BINARYLOGIC.COM")
    end
  end
end
