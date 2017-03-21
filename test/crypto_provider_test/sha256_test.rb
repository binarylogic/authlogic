require 'test_helper'

module CryptoProviderTest
  class Sha256Test < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::Sha256.encrypt("mypass")
    end

    def test_matches
      hash = Authlogic::CryptoProviders::Sha256.encrypt("mypass")
      assert Authlogic::CryptoProviders::Sha256.matches?(hash, "mypass")
    end
    
    def test_hex_case_mismatch_example_failure
      digest = Authlogic::CryptoProviders::Sha256.encrypt("mypass")
      
      # Third parties sometimes generate the digest in uppercase

      # For example Java generates hex in upper case (which is the
      # problem I had)

      # EA71C25A7A602246B4C39824B855678894A96F43BB9B71319C39700A1E045222

      # instead of 

      # ea71c25a7a602246b4c39824b855678894a96f43bb9b71319c39700a1e045222

      # While validating passwords string match fails - note the
      # not_equal
      assert_not_equal digest, digest.upcase

      # While Integer match won't
      assert_equal digest.to_i(16), digest.upcase.to_i(16)
    end

  end
end
