module Authlogic
  module ControllerAdapters # :nodoc:
    # = Abstract Adapter
    # Allows you to use Authlogic in any framework you want, not just rails. See tha RailsAdapter for an example of how to adapter Authlogic to work with your framework.
    class AbstractAdapter
      attr_accessor :controller
      
      def initialize(controller)
        self.controller = controller
      end
      
      def authenticate_with_http_basic(*args, &block)
      end
      
      def cookies
      end
      
      def request
      end
      
      def session
      end
    end
  end
end