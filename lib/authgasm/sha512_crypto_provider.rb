module Authgasm
  # = Sha512 Crypto Provider
  #
  # The acts_as_authentic method allows you to pass a :crypto_provider option. This allows you to use any type of encryption you like. Just create a class with a class level encrypt and decrypt method.
  # The password will be passed as the single parameter to each of these methods so you can do your magic.
  #
  # If you are encrypting via a hash just don't include a decrypt method, since hashes can't be decrypted. Authgasm will notice this adjust accordingly.
  class Sha512CryptoProvider
    def self.encrypt(pass)
      Digest::SHA512.hexdigest(pass)
    end
  end
end