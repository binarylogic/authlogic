# frozen_string_literal: true

require "digest/sha1"

module Authlogic
  module CryptoProviders
    # A poor choice. There are known attacks against this algorithm.
    class Sha1
      # V2 hashes the digest bytes in repeated stretches instead of hex characters.
      autoload :V2, File.join(__dir__, "sha1", "v2")

      class << self
        def join_token
          @join_token ||= "--"
        end
        attr_writer :join_token

        # The number of times to loop through the encryption.
        def stretches
          @stretches ||= 10
        end
        attr_writer :stretches

        # Turns your raw password into a Sha1 hash.
        def encrypt(*tokens)
          tokens = tokens.flatten
          digest = tokens.shift
          stretches.times do
            digest = Digest::SHA1.hexdigest([digest, *tokens].join(join_token))
          end
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
