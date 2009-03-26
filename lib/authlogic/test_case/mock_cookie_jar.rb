module Authlogic
  module TestCase
    class MockCookieJar < Hash
      def [](key)
        hash = super
        hash && hash[:value]
      end
  
      def delete(key, options = {})
        super(key)
      end
    end
  end
end