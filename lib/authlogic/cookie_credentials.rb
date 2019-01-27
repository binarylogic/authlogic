# frozen_string_literal: true

module Authlogic
  # Represents the credentials *in* the cookie. The value of the cookie.
  # This is primarily a data object. It doesn't interact with controllers.
  # It doesn't know about eg. cookie expiration.
  #
  # @api private
  class CookieCredentials
    # @api private
    class ParseError < RuntimeError
    end

    DELIMITER = "::"

    attr_reader :persistence_token, :record_id, :remember_me_until

    # @api private
    # @param persistence_token [String]
    # @param record_id [String, Numeric]
    # @param remember_me_until [ActiveSupport::TimeWithZone]
    def initialize(persistence_token, record_id, remember_me_until)
      @persistence_token = persistence_token
      @record_id = record_id
      @remember_me_until = remember_me_until
    end

    class << self
      # @api private
      def parse(string)
        parts = string.split(DELIMITER)
        unless (1..3).cover?(parts.length)
          raise ParseError, format("Expected 1..3 parts, got %d", parts.length)
        end
        new(parts[0], parts[1], parse_time(parts[2]))
      end

      private

      # @api private
      def parse_time(string)
        return if string.nil?
        ::Time.parse(string)
      rescue ::ArgumentError => e
        raise ParseError, format("Found cookie, cannot parse remember_me_until: #{e}")
      end
    end

    # @api private
    def remember_me?
      !@remember_me_until.nil?
    end

    # @api private
    def to_s
      [
        @persistence_token,
        @record_id.to_s,
        @remember_me_until&.iso8601
      ].compact.join(DELIMITER)
    end
  end
end
