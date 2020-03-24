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
      # `User` is configured to be case-sensitive. (It has a case-sensitive
      # uniqueness validation)
      ben = users(:ben)
      assert_equal ben, User.find_by_smart_case_login_field("bjohnson")
      assert_nil User.find_by_smart_case_login_field("BJOHNSON")
      assert_nil User.find_by_smart_case_login_field("Bjohnson")

      # Unlike `User`, `Employee` does not have a uniqueness validation. In
      # the absence of such, authlogic performs a case-insensitive query.
      drew = employees(:drew)
      assert_equal drew, Employee.find_by_smart_case_login_field("dgainor@binarylogic.com")
      assert_equal drew, Employee.find_by_smart_case_login_field("Dgainor@binarylogic.com")
      assert_equal drew, Employee.find_by_smart_case_login_field("DGAINOR@BINARYLOGIC.COM")
    end
  end
end
