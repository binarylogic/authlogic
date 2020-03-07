# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module VSHA1
    class V2Test < ActiveSupport::TestCase
      def setup
        @default_stretches = Authlogic::CryptoProviders::Sha1::V2.stretches
      end

      def teardown
        Authlogic::CryptoProviders::Sha1::V2.stretches = @default_stretches
      end

      def test_encrypt
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "12d995b1f0af7d24d6f89d2e63dfbcb752384815"

        digest = Authlogic::CryptoProviders::Sha1::V2.encrypt(password, salt)

        assert_equal digest, expected_digest
      end

      def test_encrypt_with_3_stretches
        Authlogic::CryptoProviders::Sha1::V2.stretches = 3
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "af1e00f841ccc742c1e5879af35ca02b1978a1ac"

        digest = Authlogic::CryptoProviders::Sha1::V2.encrypt(password, salt)

        assert_equal digest, expected_digest
      end

      def test_matches
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "12d995b1f0af7d24d6f89d2e63dfbcb752384815"

        assert Authlogic::CryptoProviders::Sha1::V2.matches?(expected_digest, password, salt)
      end

      def test_not_matches
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        bad_digest = "12345"

        assert !Authlogic::CryptoProviders::Sha1::V2.matches?(bad_digest, password, salt)
      end
    end
  end
end
