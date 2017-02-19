require "securerandom"

module Authlogic
  # Generates random strings using ruby's SecureRandom library.
  module Random
    extend self

    def hex_token
      SecureRandom.hex(64)
    end

    def friendly_token
      # use base64url as defined by RFC4648
      SecureRandom.base64(15).tr('+/=', '').strip.delete("\n")
    end
  end
end
