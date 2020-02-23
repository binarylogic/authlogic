# frozen_string_literal: true

require "test_helper"

module CryptoProviderTest
  module V2
    class SHA1Test < ActiveSupport::TestCase
      def test_encrypt
        assert Authlogic::CryptoProviders::V2::SHA1.encrypt("mypass")
      end

      def test_matches
        hash = Authlogic::CryptoProviders::V2::SHA1.encrypt("mypass")
        assert Authlogic::CryptoProviders::V2::SHA1.matches?(hash, "mypass")
      end

      def test_matches_2
        password = "test"
        salt = "abc"
        digest = "2d578fb3ab6bdab725080f00d5689f79b7d1df51"
        Authlogic::CryptoProviders::V2::SHA1.stretches = 1
        assert Authlogic::CryptoProviders::V2::SHA1.matches?(digest, nil, salt, password, nil)
        Authlogic::CryptoProviders::V2::SHA1.stretches = 10
      end
    end
  end
end
