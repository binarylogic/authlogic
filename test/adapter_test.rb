require 'test_helper'

module Authlogic
  module ControllerAdapters
    class AbstractAdapterTest < ActiveSupport::TestCase
      def test_controller
        controller = Class.new(MockController) do
          def controller.an_arbitrary_method
            'bar'
          end
        end.new
        adapter = Authlogic::ControllerAdapters::AbstractAdapter.new(controller)

        assert_equal controller, adapter.controller
        assert controller.params.equal?(adapter.params)
        assert adapter.respond_to?(:an_arbitrary_method)
        assert_equal 'bar', adapter.an_arbitrary_method
      end
    end
  end
end
