require "digest/sha2"

module Authlogic
  module CryptoProviders
    # = Sha512
    #
    # Uses the Sha512 hash algorithm to encrypt passwords.
    class Sha512
      class << self
        attr_accessor :join_token

        # The number of times to loop through the encryption. This is twenty
        # because that is what restful_authentication defaults to.
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
