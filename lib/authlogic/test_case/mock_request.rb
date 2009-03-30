module Authlogic
  module TestCase
    class MockRequest # :nodoc:
      def request_method
        nil
      end
      
      def remote_ip
        "1.1.1.1"
      end
    end
  end
end