require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class SingleAccessTest < ActiveSupport::TestCase
        def test_before_validation
          user = User.new
          assert_equal nil, user.single_access_token
          assert !user.valid?
          assert user.single_access_token
        end
        
        def test_change_with_password
          ben = users(:ben)
          old_single_access_token = ben.single_access_token
          
          User.acts_as_authentic(:change_single_access_token_with_password => true)
          ben.password = "new_pass"
          assert_not_equal old_single_access_token, ben.single_access_token
          
          ben.reload
          User.acts_as_authentic(:change_single_access_token_with_password => false)
          ben.password = "new_pass"
          assert_equal old_single_access_token, ben.single_access_token
        end
        
        def test_reset_single_access_token
          ben = users(:ben)
          old_single_access_token = ben.single_access_token
          ben.reset_single_access_token
          assert_not_equal old_single_access_token, ben.single_access_token
          ben.reload
          assert_equal old_single_access_token, ben.single_access_token
          ben.reset_single_access_token!
          assert_not_equal old_single_access_token, ben.single_access_token
        end
      end
    end
  end
end