require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class PerishabilityTest < ActiveSupport::TestCase
        def test_before_save
          ben = users(:ben)
          old_perishable_token = ben.perishable_token
          assert ben.save
          assert_not_equal old_perishable_token, ben.perishable_token
          ben.reload
          assert_not_equal old_perishable_token, ben.perishable_token
        end
        
        def test_find_using_perishable_token
          ben = users(:ben)
          assert_nil User.find_using_perishable_token("")
          assert_equal ben, User.find_using_perishable_token(ben.perishable_token)
          assert ben.class.connection.execute("update users set updated_at = '#{10.minutes.ago.to_s(:db)}' where id = '#{ben.id}';")
          assert_nil User.find_using_perishable_token(ben.perishable_token)
          assert_equal ben, User.find_using_perishable_token(ben.perishable_token, 20.minutes)
        end
        
        def test_reset_perishable_token
          ben = users(:ben)
          old_perishable_token = ben.perishable_token
          ben.reset_perishable_token
          assert_not_equal old_perishable_token, ben.perishable_token
          ben.reload
          assert_equal old_perishable_token, ben.perishable_token
          ben.reset_perishable_token!
          ben.reload
          assert_not_equal old_perishable_token, ben.perishable_token
        end
      end
    end
  end
end