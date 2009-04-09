module Authlogic
  module TestCase
    class MockRequest # :nodoc:
      def request_method
        nil
      end
      
      def referer
      end
      
      def remote_ip
        "1.1.1.1"
      end
      
      def user_agent
      end
    end
  end
end