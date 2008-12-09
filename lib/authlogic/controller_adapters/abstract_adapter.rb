module Authlogic
  module ControllerAdapters # :nodoc:
    # = Abstract Adapter
    #
    # Allows you to use Authlogic in any framework you want, not just rails. See the RailsAdapter or MerbAdapter for an example of how to adapt Authlogic to work with your framework.
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

      def request_content_type
        request.content_type
      end

      def session
        controller.session
      end
      
      private
        def method_missing(id, *args, &block)
          controller.send(id, *args, &block)
        end
    end
  end
end