require 'test_helper'

if defined?(Authlogic::CryptoProviders::SCrypt)

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
else
  puts "Your platform does not appear to support SCrypt."
end
