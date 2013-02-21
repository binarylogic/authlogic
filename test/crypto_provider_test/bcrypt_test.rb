require 'test_helper'

module CryptoProviderTest
  class BCryptTest < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::BCrypt.encrypt("mypass")
    end
    
    def test_matches
      hash = Authlogic::CryptoProviders::BCrypt.encrypt("mypass")
      assert Authlogic::CryptoProviders::BCrypt.matches?(hash, "mypass")
    end

    def test_minimum_cost
      Authlogic::CryptoProviders::BCrypt.cost = 4
      assert_equal 4, Authlogic::CryptoProviders::BCrypt.cost

      assert_raises(ArgumentError) { Authlogic::CryptoProviders::BCrypt.cost = 2 }
      assert_equal 4, Authlogic::CryptoProviders::BCrypt.cost
    end
  end
end
