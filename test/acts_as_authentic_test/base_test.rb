require 'test_helper'

module ActsAsAuthenticTest
  class BaseTest < ActiveSupport::TestCase
    def setup
      @klass = Class.new(User)
    end

    def test_acts_as_authentic
      assert_nothing_raised do
        @klass.acts_as_authentic do
        end
      end
    end

    def test_acts_as_authentic_with_old_config
      assert_raise(ArgumentError) do
        @klass.acts_as_authentic({})
      end
    end

    def test_acts_as_authentic_with_no_table
      assert_nothing_raised do
        @klass.acts_as_authentic
      end
    end
  end
end