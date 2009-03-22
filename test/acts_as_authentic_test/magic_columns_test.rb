require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class MagicColumnsTest < ActiveSupport::TestCase
    def test_validates_numericality_of_login_count
      u = User.new
      u.login_count = -1
      assert !u.valid?
      assert u.errors.on(:login_count)
      
      u.login_count = 0
      assert !u.valid?
      assert !u.errors.on(:login_count)
    end
    
    def test_validates_numericality_of_failed_login_count
      u = User.new
      u.failed_login_count = -1
      assert !u.valid?
      assert u.errors.on(:failed_login_count)
      
      u.failed_login_count = 0
      assert !u.valid?
      assert !u.errors.on(:failed_login_count)
    end
  end
end