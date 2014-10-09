require 'test_helper'

module SessionTest
  class CallbacksTest < ActiveSupport::TestCase
    def setup
      @klass = testable_user_session_class
      @klass.class_eval do
        attr_accessor :counter

        def initialize
          @counter = 0
          super
        end

        def persist_by_false
          self.counter += 1
          return false
        end

        def persist_by_true
          self.counter += 1
          return true
        end
      end
       @klass.reset_callbacks(:persist)
    end

    def test_no_callbacks
      assert_equal [], @klass._persist_callbacks.map(&:filter)
      session = @klass.new
      session.send(:persist)
      assert_equal 0, session.counter
    end

    def test_true_callback_cancelling_later_callbacks
      @klass.persist :persist_by_true, :persist_by_false
      assert_equal [:persist_by_true, :persist_by_false], @klass._persist_callbacks.map(&:filter)

      session = @klass.new
      session.send(:persist)
      assert_equal 1, session.counter
    end

    def test_false_callback_continuing_to_later_callbacks
      @klass.persist :persist_by_false, :persist_by_true
      assert_equal [:persist_by_false, :persist_by_true], @klass._persist_callbacks.map(&:filter)

      session = @klass.new
      session.send(:persist)
      assert_equal 2, session.counter
    end
  end
end
