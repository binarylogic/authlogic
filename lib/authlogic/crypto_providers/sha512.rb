require "digest/sha2"

module Authlogic
  # = Crypto Providers
  #
  # The acts_as_authentic method allows you to pass a :crypto_provider option. This allows you to use any type of encryption you like.
  # Just create a class with a class level encrypt and decrypt method. The password will be passed as the single parameter to each of these
  # methods so you can do your magic.
  #
  # If you are encrypting via a hash just don't include a decrypt method, since hashes can't be decrypted. Authlogic will notice this adjust accordingly.
  module CryptoProviders
    # = Sha512
    #
    # Uses the Sha512 hash algorithm to encrypt passwords.
    class Sha512
      class << self
        def stretches
          @stretches ||= 20
        end
        attr_writer :stretches
        
        def encrypt(pass)
          digest = pass
          stretches.times { digest = Digest::SHA512.hexdigest(digest) }
          digest
        end
      end
    end
  end
end