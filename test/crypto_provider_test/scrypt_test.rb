require 'test_helper'

module CryptoProviderTest
  class SCryptTest < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::SCrypt.encrypt("mypass")
    end

    def test_matches
      hash = Authlogic::CryptoProviders::SCrypt.encrypt("mypass")
      assert Authlogic::CryptoProviders::SCrypt.matches?(hash, "mypass")
    end
  end
end
