# frozen_string_literal: true

require "test_helper"

module ActsAsAuthenticTest
  class RestfulAuthenticationTest < ActiveSupport::TestCase
    def setup
      @old_deprecation_behavior = ::ActiveSupport::Deprecation.behavior
      ::ActiveSupport::Deprecation.behavior = :silence
    end

    def teardown
      ::ActiveSupport::Deprecation.behavior = @old_deprecation_behavior
    end

    def test_act_like_restful_authentication_config
      refute User.act_like_restful_authentication
      refute Employee.act_like_restful_authentication

      User.act_like_restful_authentication = true
      assert User.act_like_restful_authentication
      assert_equal Authlogic::CryptoProviders::Sha1, User.crypto_provider
      assert defined?(::REST_AUTH_SITE_KEY)
      assert_equal "", ::REST_AUTH_SITE_KEY
      assert_equal 1, Authlogic::CryptoProviders::Sha1.stretches

      User.act_like_restful_authentication false
      refute User.act_like_restful_authentication

      User.crypto_provider = Authlogic::CryptoProviders::Sha512
      User.transition_from_crypto_providers = []
    end

    def test_transition_from_restful_authentication_config
      refute User.transition_from_restful_authentication
      refute Employee.transition_from_restful_authentication

      User.transition_from_restful_authentication = true
      assert User.transition_from_restful_authentication
      assert defined?(::REST_AUTH_SITE_KEY)
      assert_equal "", ::REST_AUTH_SITE_KEY
      assert_equal 1, Authlogic::CryptoProviders::Sha1.stretches

      User.transition_from_restful_authentication false
      refute User.transition_from_restful_authentication
    end
  end
end
