# frozen_string_literal: true

require "test_helper"

module ActsAsAuthenticTest
  class EmailTest < ActiveSupport::TestCase
    def test_email_field_config
      assert_equal :email, User.email_field
      assert_equal :email, Employee.email_field

      User.email_field = :nope
      assert_equal :nope, User.email_field
      User.email_field :email
      assert_equal :email, User.email_field
    end

    def test_deferred_error_message_translation
      # ensure we successfully loaded the test locale
      assert I18n.available_locales.include?(:lol), "Test locale failed to load"

      I18n.with_locale("lol") do
        cat = User.new
        cat.email = "meow"
        cat.validate
        assert_includes(
          cat.errors[:email],
          I18n.t("authlogic.error_messages.email_invalid")
        )
      end
    end
  end
end
