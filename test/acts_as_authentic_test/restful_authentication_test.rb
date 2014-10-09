require 'test_helper'

module ActsAsAuthenticTest
  class RestfulAuthenticationTest < ActiveSupport::TestCase
    def test_act_like_restful_authentication_config
      klass = testable_user_class

      assert !klass.act_like_restful_authentication
      assert !User.act_like_restful_authentication
      assert !Employee.act_like_restful_authentication

      klass.act_like_restful_authentication = true
      assert klass.act_like_restful_authentication
      assert_equal Authlogic::CryptoProviders::Sha1, klass.crypto_provider
      assert defined?(::REST_AUTH_SITE_KEY)
      assert_equal '', ::REST_AUTH_SITE_KEY
      assert_equal 1, Authlogic::CryptoProviders::Sha1.stretches

      klass.act_like_restful_authentication false
      assert !klass.act_like_restful_authentication
    end

    def test_transition_from_restful_authentication_config
      klass = testable_user_class

      assert !klass.transition_from_restful_authentication
      assert !User.transition_from_restful_authentication
      assert !Employee.transition_from_restful_authentication

      klass.transition_from_restful_authentication = true
      assert klass.transition_from_restful_authentication
      assert defined?(::REST_AUTH_SITE_KEY)
      assert_equal '', ::REST_AUTH_SITE_KEY
      assert_equal 1, Authlogic::CryptoProviders::Sha1.stretches

      klass.transition_from_restful_authentication false
      assert !klass.transition_from_restful_authentication
    end
  end
end
