require "digest/sha2"

module Authlogic
  # = Crypto Providers
  #
  # The acts_as_authentic method allows you to pass a :crypto_provider option. This allows you to use any type of encryption you like.
  # Just create a class with a class level encrypt and decrypt method. The password will be passed as the single parameter to each of these
  # methods so you can do your magic.
  #
  # If you are encrypting via a hash just don't include a decrypt method, since hashes can't be decrypted. Authlogic will notice this adjust accordingly.
  #
  # === Example
  #
  #   class MyAwesomeEncryptionMethod
  #     def self.encrypt(pass)
  #       # encrypt the pass here
  #     end
  #
  #     def self.decrypt(crypted_pass)
  #       # decrypt the pass here, this is an optional method
  #       # don't even include this method if you are using a hash algorithm
  #       # this is irreverisble
  #     end
  #   end
  module CryptoProviders
    # = Sha512
    #
    # Uses the Sha512 hash algorithm to encrypt passwords.
    class Sha512
      class << self
        # The number of times to loop through the encryption. This is ten because that is what restful_authentication defaults to.
        def stretches
          @stretches ||= 20
        end
        attr_writer :stretches
        
        # Turns your raw password into a Sha512 hash.
        def encrypt(pass)
          digest = pass
          stretches.times { digest = Digest::SHA512.hexdigest(digest) }
          digest
        end
      end
    end
  end
end