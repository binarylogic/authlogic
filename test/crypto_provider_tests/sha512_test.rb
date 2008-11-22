require File.dirname(__FILE__) + '/../test_helper.rb'

module CryptoProviderTests
  class Sha512Test < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::Sha512.encrypt("mypass")
    end
  end
end