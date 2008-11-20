module Authlogic
  module ControllerAdapters # :nodoc:
    # = Abstract Adapter
    # Allows you to use Authlogic in any framework you want, not just rails. See tha RailsAdapter for an example of how to adapter Authlogic to work with your framework.
    class AbstractAdapter < SimpleDelegator
      def authenticate_with_http_basic(&block)
        @auth = Rack::Auth::Basic::Request.new(__getobj__.request.env)
        if @auth.provided? and @auth.basic?
          block.call(*@auth.credentials)
        else
          false
        end
      end
      
      def request_content_type
        request.content_type
      end
    end
  end
end