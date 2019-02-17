require "digest/md5"

::ActiveSupport::Deprecation.warn(
  <<~EOS,
    authlogic/crypto_providers/wordpress.rb is deprecated without replacement.
    Yes, the entire file. Don't `require` it. Let us know ASAP if you are still
    using it.

    Reasons for deprecation: This file is not autoloaded by
    `authlogic/crypto_providers.rb`. It's not documented. There are no tests.
    So, it's likely used by a *very* small number of people, if any. It's never
    had any contributions except by its original author, Jeffry Degrande, in
    2009. It is unclear why it should live in the main authlogic codebase. It
    could be in a separate gem, authlogic-wordpress, or it could just live in
    Jeffry's codebase, if he still even needs it, in 2018, nine years later.
  EOS
  caller(1)
)

module Authlogic
  module CryptoProviders
    # Crypto provider to transition from wordpress user accounts. Written by
    # Jeffry Degrande in 2009. First released in 2.1.3.
    #
    # Problems:
    #
    # - There are no tests.
    # - We can't even figure out how to run this without it crashing.
    # - Presumably it implements some spec, but it doesn't mention which.
    # - It is not documented anywhere.
    # - There is no PR associated with this, and no discussion about it could be found.
    #
    class Wordpress
      class << self
        ITOA64 = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".freeze

        def matches?(crypted, *tokens)
          stretches = 1 << ITOA64.index(crypted[3, 1])
          plain, salt = *tokens
          hashed = Digest::MD5.digest(salt + plain)
          stretches.times do
            hashed = Digest::MD5.digest(hashed + plain)
          end
          crypted[0, 12] + encode_64(hashed, 16) == crypted
        end

        def encode_64(input, length)
          output = ""
          i = 0
          while i < length
            value = input[i]
            i += 1
            break if value.nil?
            output += ITOA64[value & 0x3f, 1]
            value |= input[i] << 8 if i < length
            output += ITOA64[(value >> 6) & 0x3f, 1]

            i += 1
            break if i >= length
            value |= input[i] << 16 if i < length
            output += ITOA64[(value >> 12) & 0x3f, 1]

            i += 1
            break if i >= length
            output += ITOA64[(value >> 18) & 0x3f, 1]
          end
          output
        end
      end
    end
  end
end
