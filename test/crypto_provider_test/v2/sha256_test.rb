# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module V2
    class SHA256Test < ActiveSupport::TestCase
      def test_encrypt
        assert Authlogic::CryptoProviders::V2::SHA256.encrypt("mypass")
      end

      def test_matches
        hash = Authlogic::CryptoProviders::V2::SHA256.encrypt("mypass")
        assert Authlogic::CryptoProviders::V2::SHA256.matches?(hash, "mypass")
      end

      def test_matches_2
        password = "test"
        salt = "abc"
        digest = "70e0f1ade11debb6732029c267095e092b5b43ff271d4f8d9158cb004322f38b"
        Authlogic::CryptoProviders::V2::SHA256.stretches = 1
        assert Authlogic::CryptoProviders::V2::SHA256.matches?(digest, nil, salt, password, nil)
        Authlogic::CryptoProviders::V2::SHA256.stretches = 10
      end
    end
  end
end
