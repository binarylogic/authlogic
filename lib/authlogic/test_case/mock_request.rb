# frozen_string_literal: true

module Authlogic
  module TestCase
    class MockRequest # :nodoc:
      attr_accessor :controller

      def initialize(controller)
        self.controller = controller
      end

      def env
        @env ||= {
          ControllerAdapters::AbstractAdapter::ENV_SESSION_OPTIONS => {}
        }
      end

      def format
        controller.request_content_type if controller.respond_to? :request_content_type
      end

      def ip
        controller&.respond_to?(:env) &&
          controller.env.is_a?(Hash) &&
          controller.env["REMOTE_ADDR"] ||
          "1.1.1.1"
      end

      private

      def method_missing(*args, &block)
      end
    end
  end
end
