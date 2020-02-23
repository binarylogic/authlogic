# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module V2
    class MD5Test < ActiveSupport::TestCase
      def test_encrypt
        assert Authlogic::CryptoProviders::V2::MD5.encrypt("mypass")
      end

      def test_matches
        hash = Authlogic::CryptoProviders::V2::MD5.encrypt("mypass")
        assert Authlogic::CryptoProviders::V2::MD5.matches?(hash, "mypass")
      end

      def test_matches_2
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        digest = "51563330eb60e0eeb89759b01f08e872"
        Authlogic::CryptoProviders::V2::MD5.stretches = 1
        assert Authlogic::CryptoProviders::V2::MD5.matches?(digest, nil, salt, password, nil)
        Authlogic::CryptoProviders::V2::MD5.stretches = 10
      end
    end
  end
end
