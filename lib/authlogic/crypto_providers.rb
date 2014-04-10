module Authlogic
  module CryptoProviders
    autoload :MD5,    "authlogic/crypto_providers/md5"
    autoload :Sha1,   "authlogic/crypto_providers/sha1"
    autoload :Sha256, "authlogic/crypto_providers/sha256"
    autoload :Sha512, "authlogic/crypto_providers/sha512"
    autoload :BCrypt, "authlogic/crypto_providers/bcrypt"
    autoload :AES256, "authlogic/crypto_providers/aes256"
    autoload :SCrypt, "authlogic/crypto_providers/scrypt"
  end
end
