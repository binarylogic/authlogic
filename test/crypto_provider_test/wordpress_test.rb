# frozen_string_literal: true

require "test_helper"

::ActiveSupport::Deprecation.silence do
  require "authlogic/crypto_providers/wordpress"
end

module CryptoProviderTest
  class WordpressTest < ActiveSupport::TestCase
    def test_matches
      plain = "banana"
      salt = "aaa"
      crypted = "xxx0nope"
      # I couldn't figure out how to even execute this method without it
      # crashing. Maybe, when Jeffry wrote it in 2009, `Digest::MD5.digest`
      # worked differently. He was probably using ruby 1.9 back then.
      # Given that I can't even figure out how to run it, and for all the other
      # reasons I've given in `wordpress.rb`, I'm just going to deprecate
      # the whole file. -Jared 2018-04-09
      assert_raises(NoMethodError) {
        Authlogic::CryptoProviders::Wordpress.matches?(crypted, plain, salt)
      }
    end
  end
end
