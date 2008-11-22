require File.dirname(__FILE__) + '/../test_helper.rb'

module CryptoProviderTests
  class BCrpytTest < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::BCrypt.encrypt("mypass")
    end
    
    def test_decrypt
      hash = Authlogic::CryptoProviders::BCrypt.encrypt("mypass")
      assert Authlogic::CryptoProviders::BCrypt.decrypt(hash) == "mypass"
    end
  end
end