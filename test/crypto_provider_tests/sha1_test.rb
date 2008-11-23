require File.dirname(__FILE__) + '/../test_helper.rb'

module CryptoProviderTests
  class Sha1Test < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::Sha1.encrypt("mypass")
    end
    
    def test_matches
      hash = Authlogic::CryptoProviders::Sha1.encrypt("mypass")
      assert Authlogic::CryptoProviders::Sha1.matches?(hash, "mypass")
    end
  end
end