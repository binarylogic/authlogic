module Authlogic
  module TestCase
    class MockCookieJar < Hash # :nodoc:
      def [](key)
        hash = super
        hash && hash[:value]
      end

      def delete(key, _options = {})
        super(key)
      end

      def signed
        @signed ||= MockSignedCookieJar.new(self)
      end
    end

    class MockSignedCookieJar < MockCookieJar
      attr_reader :parent_jar # helper for testing

      def initialize(parent_jar)
        @parent_jar = parent_jar
      end

      def [](val)
        signed_message = @parent_jar[val]
        if signed_message
          payload, signature = signed_message.split('--')
          raise "Invalid signature" unless Digest::SHA1.hexdigest(payload) == signature
          payload
        end
      end

      def []=(key, options)
        options[:value] = "#{options[:value]}--#{Digest::SHA1.hexdigest options[:value]}"
        @parent_jar[key] = options
      end
    end
  end
end
