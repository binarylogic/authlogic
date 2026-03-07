# frozen_string_literal: true

require "argon2"

module Authlogic
  module CryptoProviders
    # Argon2id is the recommended variant of the Argon2 password hashing
    # algorithm, which won the Password Hashing Competition in 2015. It
    # combines the side-channel resistance of Argon2i with the GPU/ASIC
    # attack resistance of Argon2d, making it the best choice for
    # password hashing.
    #
    # Argon2id has three configurable cost parameters:
    #
    # - t_cost: Number of iterations (time cost). Higher values increase
    #   computation time. Default: 2
    # - m_cost: Memory usage in powers of 2 (in kibibytes).
    #   For example, m_cost of 16 means 2^16 KiB = 64 MiB.
    #   Default: 16 (64 MiB)
    # - p_cost: Degree of parallelism (number of threads). Default: 1
    #
    # To use Argon2id, install the argon2 gem:
    #
    #   gem install argon2
    #
    # Tell acts_as_authentic to use it:
    #
    #   acts_as_authentic do |c|
    #     c.crypto_provider = Authlogic::CryptoProviders::Argon2id
    #   end
    #
    # To transition from another provider (lazy migration on login):
    #
    #   acts_as_authentic do |c|
    #     c.crypto_provider = Authlogic::CryptoProviders::Argon2id
    #     c.transition_from_crypto_providers = [Authlogic::CryptoProviders::SCrypt]
    #   end
    #
    # To update cost parameters (existing passwords are re-hashed on
    # next login):
    #
    #   Authlogic::CryptoProviders::Argon2id.t_cost = 3
    #   Authlogic::CryptoProviders::Argon2id.m_cost = 17
    #
    class Argon2id
      class << self
        attr_writer :t_cost, :m_cost, :p_cost

        # Time cost (number of iterations). Default: 2
        def t_cost
          @t_cost ||= 2
        end

        # Memory cost as a power of 2 (in kibibytes). Default: 16 (64 MiB)
        def m_cost
          @m_cost ||= 16
        end

        # Parallelism (number of threads). Default: 1
        def p_cost
          @p_cost ||= 1
        end

        # Creates an Argon2id hash for the password passed.
        def encrypt(*tokens)
          hasher = ::Argon2::Password.new(
            t_cost: t_cost,
            m_cost: m_cost,
            p_cost: p_cost
          )
          hasher.create(join_tokens(tokens))
        end

        # Does the hash match the tokens? Uses the same tokens that were
        # used to encrypt.
        def matches?(hash, *tokens)
          return false if hash.blank?
          ::Argon2::Password.verify_password(join_tokens(tokens), hash)
        rescue ::Argon2::ArgonHashFail
          false
        end

        # Checks whether the existing hash uses the same cost parameters
        # as the current configuration. If not, Authlogic will re-hash
        # the password on next successful login.
        def cost_matches?(hash)
          return false if hash.blank?
          params = extract_params(hash)
          return false if params.nil?
          params[:t] == t_cost &&
            params[:m] == (1 << m_cost) &&
            params[:p] == p_cost
        end

        private

        def join_tokens(tokens)
          tokens.flatten.join
        end

        # Parses cost parameters from an Argon2id hash string.
        # Format: $argon2id$v=19$m=65536,t=2,p=1$salt$hash
        def extract_params(hash)
          match = hash.to_s.match(/\$argon2id?\$v=\d+\$m=(\d+),t=(\d+),p=(\d+)\$/)
          return nil unless match
          { m: match[1].to_i, t: match[2].to_i, p: match[3].to_i }
        end
      end
    end
  end
end
