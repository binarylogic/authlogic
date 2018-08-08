module Authlogic
  module ActsAsAuthentic
    # This module is responsible for transitioning existing applications from
    # the restful_authentication plugin.
    module RestfulAuthentication
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
        end
      end

      # Configures the restful_authentication aspect of acts_as_authentic.
      # These methods become class methods of ::ActiveRecord::Base.
      module Config
        DPR_MSG = <<~STR.squish
          Support for transitioning to authlogic from restful_authentication
          (%s) is deprecated without replacement. restful_authentication is no
          longer used in the ruby community, and the transition away from it is
          complete. There is only one version of restful_authentication on
          rubygems.org, it was released in 2009, and it's only compatible with
          rails 2.3. It has been nine years since it was released.
        STR

        # Switching an existing app to Authlogic from restful_authentication? No
        # problem, just set this true and your users won't know anything
        # changed. From your database perspective nothing will change at all.
        # Authlogic will continue to encrypt passwords just like
        # restful_authentication, so your app won't skip a beat. Although, might
        # consider transitioning your users to a newer and stronger algorithm.
        # Checkout the transition_from_restful_authentication option.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def act_like_restful_authentication(value = nil)
          r = rw_config(:act_like_restful_authentication, value, false)
          set_restful_authentication_config if value
          r
        end

        def act_like_restful_authentication=(value = nil)
          ::ActiveSupport::Deprecation.warn(
            format(DPR_MSG, "act_like_restful_authentication="),
            caller(1)
          )
          act_like_restful_authentication(value)
        end

        # This works just like act_like_restful_authentication except that it
        # will start transitioning your users to the algorithm you specify with
        # the crypto provider option. The next time they log in it will resave
        # their password with the new algorithm and any new record will use the
        # new algorithm as well. Make sure to update your users table if you are
        # using the default migration since it will set crypted_password and
        # salt columns to a maximum width of 40 characters which is not enough.
        def transition_from_restful_authentication(value = nil)
          r = rw_config(:transition_from_restful_authentication, value, false)
          set_restful_authentication_config if value
          r
        end

        def transition_from_restful_authentication=(value = nil)
          ::ActiveSupport::Deprecation.warn(
            format(DPR_MSG, "transition_from_restful_authentication="),
            caller(1)
          )
          transition_from_restful_authentication(value)
        end

        private

        def set_restful_authentication_config
          self.restful_auth_crypto_provider = CryptoProviders::Sha1
          if !defined?(::REST_AUTH_SITE_KEY) || ::REST_AUTH_SITE_KEY.nil?
            unless defined?(::REST_AUTH_SITE_KEY)
              class_eval("::REST_AUTH_SITE_KEY = ''", __FILE__, __LINE__)
            end
            CryptoProviders::Sha1.stretches = 1
          end
        end

        # @api private
        def restful_auth_crypto_provider=(provider)
          if act_like_restful_authentication
            self.crypto_provider = provider
          else
            self.transition_from_crypto_providers = provider
          end
        end
      end

      # :nodoc:
      module InstanceMethods
        private

        def act_like_restful_authentication?
          self.class.act_like_restful_authentication == true
        end

        def transition_from_restful_authentication?
          self.class.transition_from_restful_authentication == true
        end
      end
    end
  end
end
