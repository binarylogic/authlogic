module Authlogic
  module ControllerAdapters # :nodoc:
    # = Abstract Adapter
    # Allows you to use Authlogic in any framework you want, not just rails. See tha RailsAdapter for an example of how to adapter Authlogic to work with your framework.
    class AbstractAdapter
      attr_accessor :controller
      
      def initialize(controller)
        self.controller = controller
      end
      
      def authenticate_with_http_basic(&block)
        @auth = Rack::Auth::Basic::Request.new(controller.request.env)
        if @auth.provided? and @auth.basic?
          block.call(*@auth.credentials)
        else
          false
        end
      end
      
      def cookies
        controller.cookies
      end
      
      def params
        controller.params
      end
      
      def request
        controller.request
      end
      
      def session
        controller.session
      end
    end
  end
end