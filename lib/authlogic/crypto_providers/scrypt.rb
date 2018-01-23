require "scrypt"

module Authlogic
  module CryptoProviders
    # SCrypt is the default provider for Authlogic. It is the only
    # choice in the adaptive hash family that accounts for hardware
    # based attacks by compensating with memory bound as well as cpu
    # bound computational constraints. It offers the same guarantees
    # as BCrypt in the way of one-way, unique and slow.
    #
    # Decided SCrypt is for you? Just install the scrypt gem:
    #
    #   gem install scrypt
    #
    # Tell acts_as_authentic to use it:
    #
    #   acts_as_authentic do |c|
    #     c.crypto_provider = Authlogic::CryptoProviders::SCrypt
    #   end
    class SCrypt
      class << self
        DEFAULTS = { key_len: 32, salt_size: 8, max_time: 0.2, max_mem: 1024 * 1024, max_memfrac: 0.5 }.freeze

        attr_writer :key_len, :salt_size, :max_time, :max_mem, :max_memfrac
        # Key length - length in bytes of generated key, from 16 to 512.
        def key_len
          @key_len ||= DEFAULTS[:key_len]
        end

        # Salt size - size in bytes of random salt, from 8 to 32
        def salt_size
          @salt_size ||= DEFAULTS[:salt_size]
        end

        # Max time - maximum time spent in computation
        def max_time
          @max_time ||= DEFAULTS[:max_time]
        end

        # Max memory - maximum memory usage. The minimum is always 1MB
        def max_mem
          @max_mem ||= DEFAULTS[:max_mem]
        end

        # Max memory fraction - maximum memory out of all available. Always greater than zero and <= 0.5.
        def max_memfrac
          @max_memfrac ||= DEFAULTS[:max_memfrac]
        end

        # Creates an SCrypt hash for the password passed.
        def encrypt(*tokens)
          ::SCrypt::Password.create(
            join_tokens(tokens),
            key_len: key_len,
            salt_size: salt_size,
            max_mem: max_mem,
            max_memfrac: max_memfrac,
            max_time: max_time
          )
        end

        # Does the hash match the tokens? Uses the same tokens that were used to encrypt.
        def matches?(hash, *tokens)
          hash = new_from_hash(hash)
          return false if hash.blank?
          hash == join_tokens(tokens)
        end

        private

          def join_tokens(tokens)
            tokens.flatten.join
          end

          def new_from_hash(hash)
            begin
              ::SCrypt::Password.new(hash)
            rescue ::SCrypt::Errors::InvalidHash
              return nil
            end
          end
      end
    end
  end
end
