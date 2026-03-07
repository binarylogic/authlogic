# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  class Argon2idTest < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
    end

    def test_encrypt_produces_argon2id_hash
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
      assert hash.start_with?("$argon2id$")
    end

    def test_matches
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
      assert Authlogic::CryptoProviders::Argon2id.matches?(hash, "mypass")
    end

    def test_does_not_match_wrong_password
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
      refute Authlogic::CryptoProviders::Argon2id.matches?(hash, "wrongpass")
    end

    def test_does_not_match_blank_hash
      refute Authlogic::CryptoProviders::Argon2id.matches?("", "mypass")
      refute Authlogic::CryptoProviders::Argon2id.matches?(nil, "mypass")
    end

    def test_matches_with_multiple_tokens
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass", "salt123")
      assert Authlogic::CryptoProviders::Argon2id.matches?(hash, "mypass", "salt123")
      refute Authlogic::CryptoProviders::Argon2id.matches?(hash, "mypass", "othersalt")
    end

    def test_cost_matches_with_current_params
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
      assert Authlogic::CryptoProviders::Argon2id.cost_matches?(hash)
    end

    def test_cost_does_not_match_after_t_cost_change
      hash = Authlogic::CryptoProviders::Argon2id.encrypt("mypass")
      original_t_cost = Authlogic::CryptoProviders::Argon2id.t_cost
      begin
        Authlogic::CryptoProviders::Argon2id.t_cost = original_t_cost + 1
        refute Authlogic::CryptoProviders::Argon2id.cost_matches?(hash)
      ensure
        Authlogic::CryptoProviders::Argon2id.t_cost = original_t_cost
      end
    end

    def test_cost_does_not_match_blank_hash
      refute Authlogic::CryptoProviders::Argon2id.cost_matches?("")
      refute Authlogic::CryptoProviders::Argon2id.cost_matches?(nil)
    end

    def test_does_not_match_invalid_hash
      refute Authlogic::CryptoProviders::Argon2id.matches?("not_a_real_hash", "mypass")
    end
  end
end
