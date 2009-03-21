require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class PersistenceTest < ActiveSupport::TestCase
        def test_unique_token
          assert_equal 128, User.unique_token.length
          assert_equal 128, Employee.unique_token.length # make sure encryptions use hashes also

          unique_tokens = []
          1000.times { unique_tokens << User.unique_token }
          unique_tokens.uniq!

          assert_equal 1000, unique_tokens.size
        end
        
        def test_forget_all
          http_basic_auth_for(users(:ben)) { UserSession.find }
          http_basic_auth_for(users(:zack)) { UserSession.find(:ziggity_zack) }
          assert UserSession.find
          assert UserSession.find(:ziggity_zack)
          User.forget_all!
          assert !UserSession.find
          assert !UserSession.find(:ziggity_zack)
        end
        
        def test_forget
          ben = users(:ben)
          zack = users(:zack)
          http_basic_auth_for(ben) { UserSession.find }
          http_basic_auth_for(zack) { UserSession.find(:ziggity_zack) }

          assert ben.reload.logged_in?
          assert zack.reload.logged_in?

          ben.forget!

          assert !UserSession.find
          assert UserSession.find(:ziggity_zack)
        end
        
        def test_password
          ben = users(:ben)
          old_persistence_token = ben.persistence_token
          ben.password = ""
          assert_equal old_persistence_token, ben.persistence_token
          ben.password = "newpass"
          assert_not_equal old_persistence_token, ben.persistence_token
        end
      end
    end
  end
end