# frozen_string_literal: true

require "test_helper"

module ActsAsAuthenticTest
  # Miscellaneous tests for configuration options related to the `login_field`.
  class MiscellaneousLoginTest < ActiveSupport::TestCase
    def test_login_field_config
      assert_equal :login, User.login_field
      assert_nil Employee.login_field

      User.login_field = :nope
      assert_equal :nope, User.login_field
      User.login_field :login
      assert_equal :login, User.login_field
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
