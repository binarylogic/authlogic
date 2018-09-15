# frozen_string_literal: true

require "test_helper"

module SessionTest
  class ValidationTest < ActiveSupport::TestCase
    def test_errors
      session = UserSession.new
      assert_kind_of ::ActiveModel::Errors, session.errors
    end

    def test_valid
      session = UserSession.new
      refute session.valid?
      assert_nil session.record
      assert session.errors.count > 0

      ben = users(:ben)
      session.unauthorized_record = ben
      assert session.valid?
      assert_equal ben, session.attempted_record
      assert session.errors.empty?
    end
  end
end
