module Authlogic
  module Session
    # Handles all authentication that deals with cookies, such as persisting, saving, and destroying.
    module Cookies
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          persist :persist_by_cookie
          after_save :save_cookie
          after_destroy :destroy_cookie
        end
      end

      # Configuration for the cookie feature set.
      module Config
        # The name of the cookie or the key in the cookies hash. Be sure and use a unique name. If you have multiple sessions and they use the same cookie it will cause problems.
        # Also, if a id is set it will be inserted into the beginning of the string. Exmaple:
        #
        #   session = UserSession.new
        #   session.cookie_key => "user_credentials"
        #
        #   session = UserSession.new(:super_high_secret)
        #   session.cookie_key => "super_high_secret_user_credentials"
        #
        # * <tt>Default:</tt> "#{klass_name.underscore}_credentials"
        # * <tt>Accepts:</tt> String
        def cookie_key(value = nil)
          rw_config(:cookie_key, value, "#{klass_name.underscore}_credentials")
        end
        alias_method :cookie_key=, :cookie_key

        # If sessions should be remembered by default or not.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def remember_me(value = nil)
          rw_config(:remember_me, value, false)
        end
        alias_method :remember_me=, :remember_me

        # The length of time until the cookie expires.
        #
        # * <tt>Default:</tt> 3.months
        # * <tt>Accepts:</tt> Integer, length of time in seconds, such as 60 or 3.months
        def remember_me_for(value = nil)
          rw_config(:remember_me_for, value, 3.months)
        end
        alias_method :remember_me_for=, :remember_me_for

        # Should the cookie be set as secure?  If true, the cookie will only be sent over SSL connections
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def secure(value = nil)
          rw_config(:secure, value, false)
        end
        alias_method :secure=, :secure

        # Should the cookie be set as httponly?  If true, the cookie will not be accessable from javascript
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def httponly(value = nil)
          rw_config(:httponly, value, false)
        end
        alias_method :httponly=, :httponly

        # Should the cookie be signed? If the controller adapter supports it, this is a measure against cookie tampering.
        def sign_cookie(value = nil)
          if value && !controller.cookies.respond_to?(:signed)
            raise "Signed cookies not supported with #{controller.class}!"
          end
          rw_config(:sign_cookie, value, false)
        end
        alias_method :sign_cookie=, :sign_cookie
      end

      # The methods available for an Authlogic::Session::Base object that make up the cookie feature set.
      module InstanceMethods
        # Allows you to set the remember_me option when passing credentials.
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          case values.first
          when Hash
            self.remember_me = values.first.with_indifferent_access[:remember_me] if values.first.with_indifferent_access.key?(:remember_me)
          else
            r = values.find { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
            self.remember_me = r if !r.nil?
          end
        end

        # Is the cookie going to expire after the session is over, or will it stick around?
        def remember_me
          return @remember_me if defined?(@remember_me)
          @remember_me = self.class.remember_me
        end

        # Accepts a boolean as a flag to remember the session or not. Basically to expire the cookie at the end of the session or keep it for "remember_me_until".
        def remember_me=(value)
          @remember_me = value
        end

        # See remember_me
        def remember_me?
          remember_me == true || remember_me == "true" || remember_me == "1"
        end

        # How long to remember the user if remember_me is true. This is based on the class level configuration: remember_me_for
        def remember_me_for
          return unless remember_me?
          self.class.remember_me_for
        end

        # When to expire the cookie. See remember_me_for configuration option to change this.
        def remember_me_until
          return unless remember_me?
          remember_me_for.from_now
        end

        # Has the cookie expired due to current time being greater than remember_me_until.
        def remember_me_expired?
          return unless remember_me?
          (Time.parse(cookie_credentials[2]) < Time.now)
        end

        # If the cookie should be marked as secure (SSL only)
        def secure
          return @secure if defined?(@secure)
          @secure = self.class.secure
        end

        # Accepts a boolean as to whether the cookie should be marked as secure.  If true the cookie will only ever be sent over an SSL connection.
        def secure=(value)
          @secure = value
        end

        # See secure
        def secure?
          secure == true || secure == "true" || secure == "1"
        end

        # If the cookie should be marked as httponly (not accessable via javascript)
        def httponly
          return @httponly if defined?(@httponly)
          @httponly = self.class.httponly
        end

        # Accepts a boolean as to whether the cookie should be marked as httponly.  If true, the cookie will not be accessable from javascript
        def httponly=(value)
          @httponly = value
        end

        # See httponly
        def httponly?
          httponly == true || httponly == "true" || httponly == "1"
        end

        # If the cookie should be signed
        def sign_cookie
          return @sign_cookie if defined?(@sign_cookie)
          @sign_cookie = self.class.sign_cookie
        end

        # Accepts a boolean as to whether the cookie should be signed.  If true the cookie will be saved and verified using a signature.
        def sign_cookie=(value)
          @sign_cookie = value
        end

        # See sign_cookie
        def sign_cookie?
          sign_cookie == true || sign_cookie == "true" || sign_cookie == "1"
        end

        private
          def cookie_key
            build_key(self.class.cookie_key)
          end

          def cookie_credentials
            if self.class.sign_cookie
              cookie = controller.cookies.signed[cookie_key]
            else
              cookie = controller.cookies[cookie_key]
            end
            cookie && cookie.split("::")
          end

          # Tries to validate the session from information in the cookie
          def persist_by_cookie
            persistence_token, record_id = cookie_credentials
            if persistence_token.present?
              record = search_for_record("find_by_#{klass.primary_key}", record_id)
              self.unauthorized_record = record if record && record.persistence_token == persistence_token
              valid?
            else
              false
            end
          end

          def save_cookie
            if sign_cookie?
              controller.cookies.signed[cookie_key] = generate_cookie_for_saving
            else
              controller.cookies[cookie_key] = generate_cookie_for_saving
            end
          end

          def generate_cookie_for_saving
            remember_me_until_value = "::#{remember_me_until.iso8601}" if remember_me?
            {
              :value => "#{record.persistence_token}::#{record.send(record.class.primary_key)}#{remember_me_until_value}",
              :expires => remember_me_until,
              :secure => secure,
              :httponly => httponly,
              :domain => controller.cookie_domain
            }
          end

          def destroy_cookie
            controller.cookies.delete cookie_key, :domain => controller.cookie_domain
          end
      end
    end
  end
end
