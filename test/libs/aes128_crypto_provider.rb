require "ezcrypto"

class AES128CryptoProvider
  class << self
    def encrypt(*tokens)
      [key.encrypt(tokens.join)].pack("m").chomp
    end
    
    def matches?(crypted, *tokens)
      key.decrypt(crypted.unpack("m").first) == tokens.join
    end
    
    def key
      EzCrypto::Key.with_password "master_key", "some_salt"
    end
  end
end