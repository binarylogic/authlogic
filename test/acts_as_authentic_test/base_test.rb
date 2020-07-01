# frozen_string_literal: true

require "test_helper"

module ActsAsAuthenticTest
  class BaseTest < ActiveSupport::TestCase
    def test_acts_as_authentic
      assert_nothing_raised do
        User.acts_as_authentic do
        end
      end
    end

    def test_acts_as_authentic_with_old_config
      assert_raise(ArgumentError) do
        User.acts_as_authentic({})
      end
    end

    def test_acts_as_authentic_with_no_table_raise_on_model_setup_error_default
      klass = Class.new(ActiveRecord::Base)
      assert_nothing_raised do
        klass.acts_as_authentic
      end
    end

    def test_acts_as_authentic_with_no_table_raise_on_model_setup_error_enabled
      klass = Class.new(ActiveRecord::Base)
      e = assert_raises Authlogic::ModelSetupError do
        klass.acts_as_authentic do |c|
          c.raise_on_model_setup_error = true
        end
      end
      refute e.message.empty?
    end
  end
end
