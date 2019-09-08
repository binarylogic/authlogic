# frozen_string_literal: true

module Authlogic
  # Parent class of all Authlogic errors.
  class Error < StandardError
  end

  # :nodoc:
  class InvalidCryptoProvider < Error
  end

  # :nodoc:
  class NilCryptoProvider < InvalidCryptoProvider
    def message
      <<~EOS
        In version 5, Authlogic used SCrypt by default. As of version 6, there
        is no default. We still recommend SCrypt. If you previously relied on
        this default, then, in your User model (or equivalent), please set the
        following:

            acts_as_authentic do |config|
              c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
            end

        Furthermore, the authlogic gem no longer depends on the scrypt gem. In
        your Gemfile, please add scrypt.

            gem "scrypt", "~> 3.0"

        We have made this change in Authlogic 6 so that users of other crypto
        providers no longer need to install the scrypt gem.
      EOS
    end
  end
end
