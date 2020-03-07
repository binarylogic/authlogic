# frozen_string_literal: true

require "digest/sha2"

module Authlogic
  module CryptoProviders
    class Sha512
      # SHA-512 does not have any practical known attacks against it. However,
      # there are better choices. We recommend transitioning to a more secure,
      # adaptive hashing algorithm, like scrypt.
      class V2
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
            stretches.times do
              digest = Digest::SHA512.digest(digest)
            end
            digest.unpack("H*")[0]
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
end
