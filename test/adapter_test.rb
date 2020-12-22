# frozen_string_literal: true

require "test_helper"
require "authlogic/controller_adapters/rails_adapter"

module Authlogic
  module ControllerAdapters
    class AbstractAdapterTest < ActiveSupport::TestCase
      def test_controller
        controller = Class.new(MockController) do
          def controller.an_arbitrary_method
            "bar"
          end
        end.new
        adapter = Authlogic::ControllerAdapters::AbstractAdapter.new(controller)

        assert_equal controller, adapter.controller
        assert controller.params.equal?(adapter.params)
        assert adapter.respond_to?(:an_arbitrary_method)
        assert_equal "bar", adapter.an_arbitrary_method
      end
    end

    class RailsAdapterTest < ActiveSupport::TestCase
      def test_api_controller
        controller = MockAPIController.new
        adapter = Authlogic::ControllerAdapters::RailsAdapter.new(controller)

        assert_equal controller, adapter.controller
        assert_nil adapter.cookies
      end
    end

    class RailsRequestAdapterTest < ActiveSupport::TestCase
      def test_adapter_with_string_cookie
        controller = MockController.new
        controller.cookies["foo"] = "bar"
        adapter = Authlogic::TestCase::RailsRequestAdapter.new(controller)

        assert adapter.cookies
      end

      def test_adapter_with_hash_cookie
        controller = MockController.new
        controller.cookies["foo"] = {
          value: "bar",
          expires: nil
        }
        adapter = Authlogic::TestCase::RailsRequestAdapter.new(controller)

        assert adapter.cookies
      end
    end
  end
end
