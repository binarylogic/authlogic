require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class LoggedInTest < ActiveSupport::TestCase
        def test_named_scopes
          assert_equal 0, User.logged_in.count
          assert_equal User.count, User.logged_out.count
          http_basic_auth_for(users(:ben)) { UserSession.find }
          assert_equal 1, User.logged_in.count
          assert_equal User.count - 1, User.logged_out.count
        end
        
        def test_logged_in
          ben = users(:ben)
          assert !ben.logged_in?
          assert ben.update_attribute(:last_request_at, Time.now)
          assert ben.logged_in?
        end
      end
    end
  end
end