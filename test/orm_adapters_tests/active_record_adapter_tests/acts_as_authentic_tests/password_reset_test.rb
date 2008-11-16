require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class PasswordResetTest < ActiveSupport::TestCase
        def test_before_validation
          ben = users(:ben)
          old_password_reset_token = ben.password_reset_token
          assert ben.valid?
          assert_not_equal old_password_reset_token, ben.password_reset_token
          ben.reload
          assert_equal old_password_reset_token, ben.password_reset_token
          assert ben.save
          assert_not_equal old_password_reset_token, ben.password_reset_token
        end
        
        def test_find_using_password_reset_token
          ben = users(:ben)
          assert_nil User.find_using_password_reset_token("")
          assert_equal ben, User.find_using_password_reset_token(ben.password_reset_token)
          assert ben.class.connection.execute("update users set updated_at = '#{10.minutes.ago.to_s(:db)}' where id = '#{ben.id}';")
          assert_nil User.find_using_password_reset_token(ben.password_reset_token)
        end
        
        def test_reset_password_reset_token
          ben = users(:ben)
          old_password_reset_token = ben.password_reset_token
          ben.reset_password_reset_token
          assert_not_equal old_password_reset_token, ben.password_reset_token
          ben.reload
          assert_equal old_password_reset_token, ben.password_reset_token
          ben.reset_password_reset_token!
          ben.reload
          assert_not_equal old_password_reset_token, ben.password_reset_token
        end
      end
    end
  end
end