require 'test_helper'

module ActsAsAuthenticTest
  class MagicColumnsTest < ActiveSupport::TestCase
    def test_validates_numericality_of_login_count
      u = User.new
      u.login_count = -1
      refute u.valid?
      refute u.errors[:login_count].empty?

      u.login_count = 0
      refute u.valid?
      assert u.errors[:login_count].empty?
    end

    def test_validates_numericality_of_failed_login_count
      u = User.new
      u.failed_login_count = -1
      refute u.valid?
      refute u.errors[:failed_login_count].empty?

      u.failed_login_count = 0
      refute u.valid?
      assert u.errors[:failed_login_count].empty?
    end
  end
end
