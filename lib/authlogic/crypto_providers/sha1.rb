require "digest/sha1"

module Authlogic
  module CryptoProviders
    # = Sha1
    #
    # Uses the Sha1 hash algorithm to encrypt passwords. This class is useful if you are migrating from restful_authentication. This uses the
    # exact same excryption algorithm with 10 stretches, just like restful_authentication.
    class Sha1
      class << self
        def stretches
          @stretches ||= 10
        end
        attr_writer :stretches
        
        def encrypt(pass)
          digest = pass
          stretches.times { digest = Digest::SHA1.hexdigest(digest) }
          digest
        end
      end
    end
  end
end