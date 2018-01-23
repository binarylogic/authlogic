require "openssl"

module Authlogic
  module CryptoProviders
    # This encryption method is reversible if you have the supplied key. So in order to
    # use this encryption method you must supply it with a key first. In an initializer,
    # or before your application initializes, you should do the following:
    #
    #   Authlogic::CryptoProviders::AES256.key = "long, unique, and random key"
    #
    # My final comment is that this is a strong encryption method, but its main weakness
    # is that it's reversible. If you do not need to reverse the hash then you should
    # consider Sha512 or BCrypt instead.
    #
    # Keep your key in a safe place, some even say the key should be stored on a separate
    # server. This won't hurt performance because the only time it will try and access the
    # key on the separate server is during initialization, which only happens once. The
    # reasoning behind this is if someone does compromise your server they won't have the
    # key also. Basically, you don't want to store the key with the lock.
    class AES256
      class << self
        attr_writer :key

        def encrypt(*tokens)
          aes.encrypt
          aes.key = @key
          [aes.update(tokens.join) + aes.final].pack("m").chomp
        end

        def matches?(crypted, *tokens)
          aes.decrypt
          aes.key = @key
          (aes.update(crypted.unpack("m").first) + aes.final) == tokens.join
        rescue OpenSSL::CipherError
          false
        end

        private

          def aes
            if @key.blank?
              raise ArgumentError.new(
                "You must provide a key like #{name}.key = my_key before using the #{name}"
              )
            end

            @aes ||= openssl_cipher_class.new("AES-256-ECB")
          end

          # `::OpenSSL::Cipher::Cipher` has been deprecated since at least 2014,
          # in favor of `::OpenSSL::Cipher`, but a deprecation warning was not
          # printed until 2016
          # (https://github.com/ruby/openssl/commit/5c20a4c014) when openssl
          # became a gem. Its first release as a gem was 2.0.0, in ruby 2.4.
          # (See https://github.com/ruby/ruby/blob/v2_4_0/NEWS)
          def openssl_cipher_class
            if ::Gem::Version.new(::OpenSSL::VERSION) < ::Gem::Version.new("2.0.0")
              ::OpenSSL::Cipher::Cipher
            else
              ::OpenSSL::Cipher
            end
          end
      end
    end
  end
end
