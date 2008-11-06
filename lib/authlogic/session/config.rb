module Authlogic
  module Session
    module Config # :nodoc:
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.send(:include, InstanceMethods)
      end
      
      # = Config
      #
      # Configuration is simple. The configuration options are just class methods. Just put this in your config/initializers directory
      #
      #   UserSession.configure do |config|
      #     config.authenticate_with = User
      #     # ... more configuration
      #   end
      #
      # or you can set your configuration in the session class directly:
      #
      #   class UserSession < Authlogic::Session::Base
      #     authenticate_with User
      #     # ... more configuration
      #   end
      #
      # You can also access the values in the same fashion:
      #
      #   UserSession.authenticate_with
      #
      # See the methods belows for all configuration options.
      module ClassMethods
        # Lets you change which model to use for authentication.
        #
        # * <tt>Default:</tt> inferred from the class name. UserSession would automatically try User
        # * <tt>Accepts:</tt> an ActiveRecord class
        def authenticate_with(klass)
          @klass_name = klass.name
          @klass = klass
        end
        alias_method :authenticate_with=, :authenticate_with
        
        # Convenience method that lets you easily set configuration, see examples above
        def configure
          yield self
        end
        
        # The name of the cookie or the key in the cookies hash. Be sure and use a unique name. If you have multiple sessions and they use the same cookie it will cause problems.
        # Also, if a id is set it will be inserted into the beginning of the string. Exmaple:
        #
        #   session = UserSession.new(:super_high_secret)
        #   session.cookie_key => "super_high_secret_user_credentials"
        #
        # * <tt>Default:</tt> "#{klass_name.underscore}_credentials"
        # * <tt>Accepts:</tt> String
        def cookie_key(value = nil)
          if value.nil?
            read_inheritable_attribute(:cookie_key) || cookie_key("#{klass_name.underscore}_credentials")
          else
            write_inheritable_attribute(:cookie_key, value)
          end
        end
        alias_method :cookie_key=, :cookie_key
        
        # The name of the method used to find the record by the login. What's nifty about this is that you can do anything in your method, Authlogic will just pass you the login.
        #
        # Let's say you allow users to login by username or email. Set this to "find_login", or whatever method you want. Then in your model create a class method like:
        #
        #   def self.find_login(login)
        #     find_by_login(login) || find_by_email(login)
        #   end
        #
        # * <tt>Default:</tt> "find_by_#{login_field}"
        # * <tt>Accepts:</tt> Symbol or String
        def find_by_login_method(value = nil)
          if value.nil?
            read_inheritable_attribute(:find_by_login_method) || find_by_login_method("find_by_#{login_field}")
          else
            write_inheritable_attribute(:find_by_login_method, value)
          end
        end
        alias_method :find_by_login_method=, :find_by_login_method
        
        # Calling UserSession.find tries to find the user session by session, then cookie, then basic http auth. This option allows you to change the order or remove any of these.
        #
        # * <tt>Default:</tt> [:session, :cookie, :http_auth]
        # * <tt>Accepts:</tt> Array, and can only use any of the 3 options above
        def find_with(*values)
          if values.blank?
            read_inheritable_attribute(:find_with) || find_with(:session, :cookie, :http_auth)
          else
            values.flatten!
            write_inheritable_attribute(:find_with, values)
          end
        end
        alias_method :find_with=, :find_with
        
        # The name of the method you want Authlogic to create for storing the login / username. Keep in mind this is just for your Authlogic::Session, if you want it can be something completely different
        # than the field in your model. So if you wanted people to login with a field called "login" and then find users by email this is compeltely doable. See the find_by_login_method configuration option for
        # more details.
        #
        # * <tt>Default:</tt> Guesses based on the model columns, tries login, username, and email. If none are present it defaults to login
        # * <tt>Accepts:</tt> Symbol or String
        def login_field(value = nil)
          if value.nil?
            read_inheritable_attribute(:login_field) || login_field((klass.column_names.include?("login") && :login) || (klass.column_names.include?("username") && :username) || (klass.column_names.include?("email") && :email) || :login)
          else
            write_inheritable_attribute(:login_field, value)
          end
        end
        alias_method :login_field=, :login_field
        
        # Works exactly like login_field, but for the password instead.
        #
        # * <tt>Default:</tt> Guesses based on the model columns, tries password and pass. If none are present it defaults to password
        # * <tt>Accepts:</tt> Symbol or String
        def password_field(value = nil)
          if value.nil?
            read_inheritable_attribute(:password_field) || password_field((klass.column_names.include?("password") && :password) || (klass.column_names.include?("pass") && :pass) || :password)
          else
            write_inheritable_attribute(:password_field, value)
          end
        end
        alias_method :password_field=, :password_field
        
        # If sessions should be remembered by default or not.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def remember_me(value = nil)
          if value.nil?
            read_inheritable_attribute(:remember_me)
          else
            write_inheritable_attribute(:remember_me, value)
          end
        end
        alias_method :remember_me=, :remember_me
        
        # The length of time until the cookie expires.
        #
        # * <tt>Default:</tt> 3.months
        # * <tt>Accepts:</tt> Integer, length of time in seconds, such as 60 or 3.months
        def remember_me_for(value = :_read)
          if value == :_read
            read_inheritable_attribute(:remember_me_for) || remember_me_for(3.months)
          else
            write_inheritable_attribute(:remember_me_for, value)
          end
        end
        alias_method :remember_me_for=, :remember_me_for
        
        # The name of the field that the remember token is stored. This is for cookies. Let's say you set up your app and want all users to be remembered for 6 months. Then you realize that might be a little too
        # long. Well they already have a cookie set to expire in 6 months. Without a token you would have to reset their password, which obviously isn't feasible. So instead of messing with their password
        # just reset their remember token. Next time they access the site and try to login via a cookie it will be rejected and they will have to relogin.
        #
        # * <tt>Default:</tt> Guesses based on the model columns, tries remember_token, remember_key, cookie_token, and cookie_key. If none are present it defaults to remember_token
        # * <tt>Accepts:</tt> Symbol or String
        def remember_token_field(value = nil)
          if value.nil?
            read_inheritable_attribute(:remember_token_field) ||
            remember_token_field(
              (klass.column_names.include?("remember_token") && :remember_token) ||
              (klass.column_names.include?("remember_key") && :remember_key) ||
              (klass.column_names.include?("cookie_token") && :cookie_token) ||
              (klass.column_names.include?("cookie_key") && :cookie_key) ||
              :remember_token
            )
          else
            write_inheritable_attribute(:remember_token_field, value)
          end
        end
        alias_method :remember_token_field=, :remember_token_field
        
        # Works exactly like cookie_key, but for sessions. See cookie_key for more info.
        #
        # * <tt>Default:</tt> cookie_key
        # * <tt>Accepts:</tt> Symbol or String
        def session_key(value = nil)
          if value.nil?
            read_inheritable_attribute(:session_key) || session_key(cookie_key)
          else
            write_inheritable_attribute(:session_key, value)
          end
        end
        alias_method :session_key=, :session_key
        
        # The name of the method in your model used to verify the password. This should be an instance method. It should also be prepared to accept a raw password and a crytped password.
        #
        # * <tt>Default:</tt> "valid_#{password_field}?"
        # * <tt>Accepts:</tt> Symbol or String
        def verify_password_method(value = nil)
          if value.nil?
            read_inheritable_attribute(:verify_password_method) || verify_password_method("valid_#{password_field}?")
          else
            write_inheritable_attribute(:verify_password_method, value)
          end
        end
        alias_method :verify_password_method=, :verify_password_method
      end
      
      module InstanceMethods # :nodoc:
        def cookie_key
          key_parts = [id, scope[:id], self.class.cookie_key].compact
          key_parts.join("_")
        end
        
        def find_by_login_method
          self.class.find_by_login_method
        end
        
        def find_with
          self.class.find_with
        end
      
        def login_field
          self.class.login_field
        end
      
        def password_field
          self.class.password_field
        end
        
        def remember_me_for
          return unless remember_me?
          self.class.remember_me_for
        end
        
        def remember_token_field
          self.class.remember_token_field
        end
        
        def session_key
          key_parts = [id, scope[:id], self.class.session_key].compact
          key_parts.join("_")
        end
      
        def verify_password_method
          self.class.verify_password_method
        end
      end
    end
  end
end