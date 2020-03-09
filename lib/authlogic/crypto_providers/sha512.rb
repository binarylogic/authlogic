# frozen_string_literal: true

require "digest/sha2"

module Authlogic
  module CryptoProviders
    # SHA-512 does not have any practical known attacks against it. However,
    # there are better choices. We recommend transitioning to a more secure,
    # adaptive hashing algorithm, like scrypt.
    class Sha512
      # V2 hashes the digest bytes in repeated stretches instead of hex characters.
      autoload :V2, File.join(__dir__, "sha512", "v2")

      class << self
        attr_accessor :join_token

        # The number of times to loop through the encryption.
        def stretches
          @stretches ||= 20
        end
        attr_writer :stretches

        # Turns your raw password into a Sha512 hash.
        def encrypt(*tokens)
          digest = tokens.flatten.join(join_token)
          stretches.times { digest = Digest::SHA512.hexdigest(digest) }
          digest
        end

        # Does the crypted password match the tokens? Uses the same tokens that
        # were used to encrypt.
        def matches?(crypted, *tokens)
          encrypt(*tokens) == crypted
        end
      end
    end
  end
end
