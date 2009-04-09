module Authlogic
  module TestCase
    class MockRequest # :nodoc:
      attr_accessor :controller
      
      def initialize(controller)
        self.controller = controller
      end
      
      def request_method
        nil
      end
      
      def referer
      end
      
      def remote_ip
        (controller && controller.respond_to?(:env) && controller.env.is_a?(Hash) && controller.env['REMOTE_ADDR']) || "1.1.1.1"
      end
      
      def user_agent
      end
    end
  end
end