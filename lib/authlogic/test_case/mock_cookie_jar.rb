# frozen_string_literal: true

module Authlogic
  module TestCase
    # A mock of `ActionDispatch::Cookies::CookieJar`.
    class MockCookieJar < Hash # :nodoc:
      attr_accessor :set_cookies

      def [](key)
        hash = super
        hash && hash[:value]
      end

      def []=(key, options)
        (@set_cookies ||= {})[key.to_s] = options
        super
      end

      def delete(key, _options = {})
        super(key)
      end

      def signed
        @signed ||= MockSignedCookieJar.new(self)
      end
    end

    # A mock of `ActionDispatch::Cookies::SignedKeyRotatingCookieJar`
    #
    # > .. a jar that'll automatically generate a signed representation of
    # > cookie value and verify it when reading from the cookie again.
    # > actionpack/lib/action_dispatch/middleware/cookies.rb
    class MockSignedCookieJar < MockCookieJar
      attr_reader :parent_jar # helper for testing

      def initialize(parent_jar)
        @parent_jar = parent_jar
      end

      def [](val)
        signed_message = @parent_jar[val]
        if signed_message
          payload, signature = signed_message.split("--")
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
