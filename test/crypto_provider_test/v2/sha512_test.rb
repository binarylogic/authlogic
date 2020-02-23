# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module V2
    class SHA512Test < ActiveSupport::TestCase
      def test_encrypt
        assert Authlogic::CryptoProviders::V2::SHA512.encrypt("mypass")
      end

      def test_matches
        hash = Authlogic::CryptoProviders::V2::SHA512.encrypt("mypass")
        assert Authlogic::CryptoProviders::V2::SHA512.matches?(hash, "mypass")
      end

      def test_matches_2
        password = "test"
        salt = "abc"
        # rubocop:disable Metrics/LineLength
        digest = "c7cb2b81ccbb686eaefafbfbcf61334fb75f8e5dcb3de8b86fec53ad1a5dd013c0c4c9cc3af7c59aed2afab59dd463f6a84d9531f46e2efeb3681bd79bf57a37"
        # rubocop:enable Metrics/LineLength
        Authlogic::CryptoProviders::V2::SHA512.stretches = 1
        assert Authlogic::CryptoProviders::V2::SHA512.matches?(digest, nil, salt, password, nil)
        Authlogic::CryptoProviders::V2::SHA512.stretches = 10
      end
    end
  end
end
