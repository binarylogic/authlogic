# frozen_string_literal: true

module Authlogic
  module TestCase
    # Basically acts like an API controller but doesn't do anything.
    # Authlogic can interact with this, do it's thing and then you can look at
    # the controller object to see if anything changed.
    class MockAPIController < ControllerAdapters::AbstractAdapter
      attr_writer :request_content_type

      def initialize
      end

      # Expected API controller has no cookies method.
      undef :cookies

      def cookie_domain
        nil
      end

      def logger
        @logger ||= MockLogger.new
      end

      def params
        @params ||= {}
      end

      def request
        @request ||= MockRequest.new(self)
      end

      def request_content_type
        @request_content_type ||= "text/html"
      end

      def session
        @session ||= {}
      end

      # If method is defined, it causes below behavior...
      #   controller = Authlogic::ControllerAdapters::RailsAdapter.new(
      #     Authlogic::TestCase::MockAPIController.new
      #   )
      #   controller.responds_to_single_access_allowed? #=> true
      #   controller.single_access_allowed?
      #     #=> NoMethodError: undefined method `single_access_allowed?' for nil:NilClass
      #
      undef :single_access_allowed?
    end
  end
end
