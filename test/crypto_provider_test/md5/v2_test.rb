# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module MD5
    class V2Test < ActiveSupport::TestCase
      def setup
        @default_stretches = Authlogic::CryptoProviders::MD5::V2.stretches
      end

      def teardown
        Authlogic::CryptoProviders::MD5::V2.stretches = @default_stretches
      end

      def test_encrypt
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "3d16884295a68fec30a2ae7ff0634b1e"

        digest = Authlogic::CryptoProviders::MD5::V2.encrypt(password, salt)

        assert_equal digest, expected_digest
      end

      def test_encrypt_with_3_stretches
        Authlogic::CryptoProviders::MD5::V2.stretches = 3
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "da62ac8b983606f684cea0b93a558283"

        digest = Authlogic::CryptoProviders::MD5::V2.encrypt(password, salt)

        assert_equal digest, expected_digest
      end

      def test_matches
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        expected_digest = "3d16884295a68fec30a2ae7ff0634b1e"

        assert Authlogic::CryptoProviders::MD5::V2.matches?(expected_digest, password, salt)
      end

      def test_not_matches
        password = "test"
        salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
        bad_digest = "12345"

        assert !Authlogic::CryptoProviders::MD5::V2.matches?(bad_digest, password, salt)
      end
    end
  end
end
