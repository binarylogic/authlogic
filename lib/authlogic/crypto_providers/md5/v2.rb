# frozen_string_literal: true

require "digest/md5"

module Authlogic
  module CryptoProviders
    class MD5
      # A poor choice. There are known attacks against this algorithm.
      class V2
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
            stretches.times { digest = Digest::MD5.digest(digest) }
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
