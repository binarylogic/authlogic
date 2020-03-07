# frozen_string_literal: true

require "digest/md5"

module Authlogic
  module CryptoProviders
    # A poor choice. There are known attacks against this algorithm.
    class MD5
      # V2 hashes the digest bytes in repeated stretches instead of hex characters.
      autoload :V2, File.join(__dir__, "md5", "v2")

      class << self
        attr_accessor :join_token

        # The number of times to loop through the encryption.
        def stretches
          @stretches ||= 1
        end
        attr_writer :stretches

        # Turns your raw password into a MD5 hash.
        def encrypt(*tokens)
          digest = tokens.flatten.join(join_token)
          stretches.times { digest = Digest::MD5.hexdigest(digest) }
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
