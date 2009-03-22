require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class BaseTest < ActiveSupport::TestCase
    def test_acts_as_authentic
      assert_nothing_raised do
        User.acts_as_authentic do |c|
        end
      end
      
      assert User.respond_to?(:aaa_config)
      assert User.new.respond_to?(:aaa_config)
    end
  end
end