module Authlogic
  module ControllerAdapters # :nodoc:
    # = Abstract Adapter
    # Allows you to use Authlogic in any framework you want, not just rails. See tha RailsAdapter for an example of how to adapter Authlogic to work with your framework.
    class AbstractAdapter
      def authenticate_with_http_basic(&block)
        black.call(nil, nil)
      end
      
      def cookies
        {}
      end
      
      def request
        nil
      end
      
      def session
        {}
      end
    end
  end
end