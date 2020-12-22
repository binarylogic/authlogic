# frozen_string_literal: true

module Authlogic
  module TestCase
    # A mock of `ActionDispatch::Cookies::CookieJar`.
    # See action_dispatch/middleware/cookies.rb
    class MockCookieJar < Hash # :nodoc:
      attr_accessor :set_cookies

      def [](key)
        hash = super
        hash && hash[:value]
      end

      # @param options - "the cookie's value [usually a string] or a hash of
      # options as documented above [in action_dispatch/middleware/cookies.rb]"
      def []=(key, options)
        opt = cookie_options_to_hash(options)
        (@set_cookies ||= {})[key.to_s] = opt
        super(key, opt)
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

      private

      # @api private
      def cookie_options_to_hash(options)
        if options.is_a?(Hash)
          options
        else
          { value: options }
        end
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
        opt = cookie_options_to_hash(options)
        opt[:value] = "#{opt[:value]}--#{Digest::SHA1.hexdigest opt[:value]}"
        @parent_jar[key] = opt
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
        opt = cookie_options_to_hash(options)
        opt[:value] = self.class.encrypt(opt[:value])
        @parent_jar[key] = opt
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
