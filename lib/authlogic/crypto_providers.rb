# frozen_string_literal: true

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
    autoload :SCrypt, "authlogic/crypto_providers/scrypt"

    # Guide users to choose a better crypto provider.
    class Guidance
      BUILTIN_PROVIDER_PREFIX = "Authlogic::CryptoProviders::"
      NONADAPTIVE_ALGORITHM = <<~EOS
        You have selected %s as your authlogic crypto provider. This algorithm
        does not have any practical known attacks against it. However, there are
        better choices.

        Authlogic has no plans yet to deprecate this crypto provider. However,
        we recommend transitioning to a more secure, adaptive hashing algorithm,
        like scrypt. Adaptive algorithms are designed to slow down brute force
        attacks, and over time the iteration count can be increased to make it
        slower, so it remains resistant to brute-force search attacks even in
        the face of increasing computation power.

        Use the transition_from_crypto_providers option to make the transition
        painless for your users.
      EOS
      VULNERABLE_ALGORITHM = <<~EOS
        You have selected %s as your authlogic crypto provider. It is a poor
        choice because there are known attacks against this algorithm.

        Authlogic has no plans yet to deprecate this crypto provider. However,
        we recommend transitioning to a secure hashing algorithm. We recommend
        an adaptive algorithm, like scrypt.

        Use the transition_from_crypto_providers option to make the transition
        painless for your users.
      EOS

      def initialize(provider)
        @provider = provider
      end

      def impart_wisdom
        return unless @provider.is_a?(Class)

        # We can only impart wisdom about our own built-in providers.
        absolute_name = @provider.name
        return unless absolute_name.start_with?(BUILTIN_PROVIDER_PREFIX)

        # Inspect the string name of the provider, rather than using the
        # constants in our `when` clauses. If we used the constants, we'd
        # negate the benefits of the `autoload` above.
        name = absolute_name.demodulize
        case name
        when "MD5", "Sha1"
          warn(format(VULNERABLE_ALGORITHM, name))
        when "Sha256", "Sha512"
          warn(format(NONADAPTIVE_ALGORITHM, name))
        end
      end
    end
  end
end
