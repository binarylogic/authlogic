module Authlogic
  # The acts_as_authentic method has a crypto_provider option. This allows you
  # to use any type of encryption you like. Just create a class with a class
  # level encrypt and matches? method. See example below.
  #
  # === Example
  #
  #   class MyAwesomeEncryptionMethod
  #     def self.encrypt(*tokens)
  #       # The tokens passed will be an array of objects, what type of object
  #       # is irrelevant, just do what you need to do with them and return a
  #       # single encrypted string. For example, you will most likely join all
  #       # of the objects into a single string and then encrypt that string.
  #     end
  #
  #     def self.matches?(crypted, *tokens)
  #       # Return true if the crypted string matches the tokens. Depending on
  #       # your algorithm you might decrypt the string then compare it to the
  #       # token, or you might encrypt the tokens and make sure it matches the
  #       # crypted string, its up to you.
  #     end
  #   end
  module CryptoProviders
    autoload :MD5,    "authlogic/crypto_providers/md5"
    autoload :Sha1,   "authlogic/crypto_providers/sha1"
    autoload :Sha256, "authlogic/crypto_providers/sha256"
    autoload :Sha512, "authlogic/crypto_providers/sha512"
    autoload :BCrypt, "authlogic/crypto_providers/bcrypt"
    autoload :AES256, "authlogic/crypto_providers/aes256"
    autoload :SCrypt, "authlogic/crypto_providers/scrypt"
    # crypto_providers/wordpress.rb has never been autoloaded, and now it is
    # deprecated.
  end
end
