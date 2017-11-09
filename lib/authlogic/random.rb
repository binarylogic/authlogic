require "securerandom"

module Authlogic
  # Generates random strings using ruby's SecureRandom library.
  module Random
    def self.hex_token
      SecureRandom.hex(64)
    end

    # Returns a string in base64url format as defined by RFC-3548 and RFC-4648.
    # We call this a "friendly" token because it is short and safe for URLs.
    def self.friendly_token
      SecureRandom.urlsafe_base64(15)
    end
  end
end
