require File.dirname(__FILE__) + '/../test_helper.rb'

module CryptoProviderTests
  class Sha1Test < ActiveSupport::TestCase
    def test_encrypt
      assert Authlogic::CryptoProviders::Sha1.encrypt("mypass")
    end
  end
end