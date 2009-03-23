require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class PerishableTokenTest < ActiveSupport::TestCase
    def test_perishable_token_valid_for_config
      assert_equal 10.minutes.to_i, User.perishable_token_valid_for
      assert_equal 10.minutes.to_i, Employee.perishable_token_valid_for
      
      User.perishable_token_valid_for = 1.hour
      assert_equal 1.hour.to_i, User.perishable_token_valid_for
      User.perishable_token_valid_for 10.minutes
      assert_equal 10.minutes.to_i, User.perishable_token_valid_for
    end
    
    def test_disable_perishable_token_maintenance_config
      assert !User.disable_perishable_token_maintenance
      assert !Employee.disable_perishable_token_maintenance
      
      User.disable_perishable_token_maintenance = true
      assert User.disable_perishable_token_maintenance
      User.disable_perishable_token_maintenance false
      assert !User.disable_perishable_token_maintenance
    end
    
    def test_validates_uniqueness_of_perishable_token
      u = User.new
      u.perishable_token = users(:ben).perishable_token
      assert !u.valid?
      assert u.errors.on(:perishable_token)
    end
    
    def test_before_save_reset_perishable_token
      ben = users(:ben)
      old_perishable_token = ben.perishable_token
      assert ben.save
      assert_not_equal old_perishable_token, ben.perishable_token
    end
    
    def test_reset_perishable_token
      ben = users(:ben)
      old_perishable_token = ben.perishable_token
      
      assert ben.reset_perishable_token
      assert_not_equal old_perishable_token, ben.perishable_token
      
      ben.reload
      assert_equal old_perishable_token, ben.perishable_token
      
      assert ben.reset_perishable_token!
      assert_not_equal old_perishable_token, ben.perishable_token
      
      ben.reload
      assert_not_equal old_perishable_token, ben.perishable_token
    end
  end
end