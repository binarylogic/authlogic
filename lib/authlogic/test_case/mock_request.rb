module Authlogic
  module TestCase
    class MockRequest
      def remote_ip
        "1.1.1.1"
      end
    end
  end
end