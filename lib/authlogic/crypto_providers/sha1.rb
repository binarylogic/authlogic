require "digest/sha1"

module Authlogic
  module CryptoProviders
    # = Sha1
    #
    # Uses the Sha1 hash algorithm to encrypt passwords. This class is useful if you are migrating from restful_authentication. This uses the
    # exact same excryption algorithm with 10 stretches, just like restful_authentication.
    class Sha1
      class << self
        # The number of times to loop through the encryption. This is ten because that is what restful_authentication defaults to.
        def stretches
          @stretches ||= 10
        end
        attr_writer :stretches
        
        # Turns your raw password into a Sha1 hash.
        def encrypt(pass)
          digest = pass
          stretches.times { digest = Digest::SHA1.hexdigest(digest) }
          digest
        end
      end
    end
  end
end