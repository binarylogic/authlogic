require "ezcrypto"

class AES128CryptoProvider
  class << self
    def encrypt(term)
      [key.encrypt(term)].pack("m").chomp
    end
    
    def decrypt(term)
      key.decrypt(term.unpack("m").first)
    end
    
    def key
      EzCrypto::Key.with_password "master_key", "some_salt"
    end
  end
end