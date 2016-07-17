require 'test_helper'

class TestUserSession < Authlogic::Session::Base; end

class TestUser < ActiveRecord::Base
  self.table_name = "users"
  acts_as_authentic
  attr_accessor :counter
  def initialize(*args)
    @counter = 0
    super
  end
end


module ActsAsAuthenticTest
  class CallbacksTest < ActiveSupport::TestCase
    def setup
      TestUser.reset_callbacks(:password_set)
      TestUser.reset_callbacks(:password_verification)

      @u = TestUser.create(:password => "good password", :password_confirmation => "good password", :login => "awesome", :email => "awesome@awesome.com").reload
    end

    def test_password_setter_runs_callbacks
      TestUser.before_password_set { |s| s.counter += 1 }
      TestUser.after_password_set { |s| s.counter += 1 }

      assert_equal 0, @u.counter
      @u.password = "blah"
      assert_equal 2, @u.counter
    end


    def test_valid_password_with_bad_password_runs_callbacks
      TestUser.before_password_verification { |s| s.counter += 1 }
      TestUser.after_password_verification { |s| s.counter += 1 }

      assert_equal 0, @u.counter
      assert !@u.valid_password?("bad password")
      assert_equal 1, @u.counter
    end

    def test_valid_password_with_good_password_runs_callbacks
      TestUser.before_password_verification { |s| s.counter += 1 }
      TestUser.after_password_verification { |s| s.counter += 1 }

      assert_equal 0, @u.counter
      assert @u.valid_password?("good password")
      assert_equal 2, @u.counter
    end
  end
end
