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
        options = { value: options } unless options.is_a?(Hash)
        (@set_cookies ||= {})[key.to_s] = options
        super
      end

      def delete(key, _options = {})
        super(key)
      end

      def signed
        @signed ||= MockSignedCookieJar.new(self)
      end

      def encrypted
        @encrypted ||= MockEncryptedCookieJar.new(self)
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
        parent_jar.each { |k, v| self[k] = v }
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
        options = { value: options } unless options.is_a?(Hash)
        options[:value] = "#{options[:value]}--#{Digest::SHA1.hexdigest options[:value]}"
        @parent_jar[key] = options
      end
    end

    # Which ActionDispatch class is this a mock of?
    # TODO: Document as with other mocks above.
    class MockEncryptedCookieJar < MockCookieJar
      attr_reader :parent_jar # helper for testing

      def initialize(parent_jar)
        @parent_jar = parent_jar
        parent_jar.each { |k, v| self[k] = v }
      end

      def [](val)
        encrypted_message = @parent_jar[val]
        if encrypted_message
          self.class.decrypt(encrypted_message)
        end
      end

      def []=(key, options)
        options = { value: options } unless options.is_a?(Hash)
        options[:value] = self.class.encrypt(options[:value])
        @parent_jar[key] = options
      end

      # simple caesar cipher for testing
      def self.encrypt(str)
        str.unpack("U*").map(&:succ).pack("U*")
      end

      def self.decrypt(str)
        str.unpack("U*").map(&:pred).pack("U*")
      end
    end
  end
end
