# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  class Sha512Test < ActiveSupport::TestCase
    def setup
      @default_stretches = Authlogic::CryptoProviders::Sha512.stretches
    end

    def teardown
      Authlogic::CryptoProviders::Sha512.stretches = @default_stretches
    end

    def test_encrypt
      password = "test"
      salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
      expected_digest = "9508ba2964d65501aa1d7798e8f250b35f50fadb870871f2bc1f" \
        "390872e8456e785633d06e17ffa4984a04cfa1a0e1ec29f15c31187b991e591393c6c0bffb61"
      digest = Authlogic::CryptoProviders::Sha512.encrypt(password, salt)
      assert_equal digest, expected_digest
    end

    def test_encrypt_with_3_stretches
      Authlogic::CryptoProviders::Sha512.stretches = 3
      password = "test"
      salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
      expected_digest = "ed507752ef2e985a9e5661fedcbac8ad7536d4b80c87183c2027" \
        "3f568afb6f2112886fd786de00458eb2a14c640d9060c4688825e715cc1c3ecde8997d4ae556"
      digest = Authlogic::CryptoProviders::Sha512.encrypt(password, salt)
      assert_equal digest, expected_digest
    end

    def test_matches
      password = "test"
      salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
      expected_digest = "9508ba2964d65501aa1d7798e8f250b35f50fadb870871f2bc1f" \
        "390872e8456e785633d06e17ffa4984a04cfa1a0e1ec29f15c31187b991e591393c6c0bffb61"
      assert Authlogic::CryptoProviders::Sha512.matches?(expected_digest, password, salt)
    end

    def test_not_matches
      password = "test"
      salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
      bad_digest = "12345"
      assert !Authlogic::CryptoProviders::Sha512.matches?(bad_digest, password, salt)
    end
  end
end
