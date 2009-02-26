module Authlogic
  module Session
    module Config # :nodoc:
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.send(:include, InstanceMethods)
      end
      
      # = Session Config
      #
      # This deals with configuration for your session. If you are wanting to configure your model please look at Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::Config
      #
      # Configuration for your session is simple. The configuration options are just class methods. Just put this in your config/initializers directory
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
        #   session = UserSession.new
        #   session.cookie_key => "user_credentials"
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
        
        # Set this to true if you want to disable the checking of active?, approved?, and confirmed? on your record. This is more or less of a
        # convenience feature, since 99% of the time if those methods exist and return false you will not want the user logging in. You could
        # easily accomplish this same thing with a before_validation method or other callbacks.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def disable_magic_states(value = nil)
          if value.nil?
            read_inheritable_attribute(:disable_magic_states)
          else
            write_inheritable_attribute(:disable_magic_states, value)
          end
        end
        alias_method :disable_magic_states=, :disable_magic_states
        
        # Authlogic tries to validate the credentials passed to it. One part of validation is actually finding the user and making sure it exists. What method it uses the do this is up to you.
        #
        # Let's say you have a UserSession that is authenticating a User. By default UserSession will call User.find_by_login(login). You can change what method UserSession calls by specifying it here. Then
        # in your User model you can make that method do anything you want, giving you complete control of how users are found by the UserSession.
        #
        # Let's take an example: You want to allow users to login by username or email. Set this to the name of the class method that does this in the User model. Let's call it "find_by_username_or_email"
        #
        #   class User < ActiveRecord::Base
        #     def self.find_by_username_or_email(login)
        #       find_by_username(login) || find_by_email(login)
        #     end
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
        
        # Calling UserSession.find tries to find the user session by cookie, then session, then params, and finally by basic http auth.
        # This option allows you to change the order or remove any of these.
        #
        # * <tt>Default:</tt> [:params, :cookie, :session, :http_auth]
        # * <tt>Accepts:</tt> Array, and can only use any of the 3 options above
        def find_with(*values)
          if values.blank?
            read_inheritable_attribute(:find_with) || find_with(:params, :cookie, :session, :http_auth)
          else
            values.flatten!
            write_inheritable_attribute(:find_with, values)
          end
        end
        alias_method :find_with=, :find_with
        
        # Every time a session is found the last_request_at field for that record is updatd with the current time, if that field exists. If you want to limit how frequent that field is updated specify the threshold
        # here. For example, if your user is making a request every 5 seconds, and you feel this is too frequent, and feel a minute is a good threashold. Set this to 1.minute. Once a minute has passed in between
        # requests the field will be updated.
        #
        # * <tt>Default:</tt> 0
        # * <tt>Accepts:</tt> integer representing time in seconds
        def last_request_at_threshold(value = nil)
          if value.nil?
            read_inheritable_attribute(:last_request_at_threshold) || last_request_at_threshold(0)
          else
            write_inheritable_attribute(:last_request_at_threshold, value)
          end
        end
        alias_method :last_request_at_threshold=, :last_request_at_threshold
        
        def login_blank_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :login_blank_message=, :login_blank_message
        
        def login_not_found_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :login_not_found_message=, :login_not_found_message
        
        # The name of the method you want Authlogic to create for storing the login / username. Keep in mind this is just for your
        # Authlogic::Session, if you want it can be something completely different than the field in your model. So if you wanted people to
        # login with a field called "login" and then find users by email this is compeltely doable. See the find_by_login_method configuration
        # option for more details.
        #
        # * <tt>Default:</tt> Uses the configuration option in your model: User.acts_as_authentic_config[:login_field]
        # * <tt>Accepts:</tt> Symbol or String
        def login_field(value = nil)
          if value.nil?
            read_inheritable_attribute(:login_field) || login_field(klass.acts_as_authentic_config[:login_field])
          else
            write_inheritable_attribute(:login_field, value)
          end
        end
        alias_method :login_field=, :login_field
        
        # With acts_as_authentic you get a :logged_in_timeout configuration option. If this is set, after this amount of time has passed the user
        # will be marked as logged out. Obviously, since web based apps are on a per request basis, we have to define a time limit threshold that
        # determines when we consider a user to be "logged out". Meaning, if they login and then leave the website, when do mark them as logged out?
        # I recommend just using this as a fun feature on your website or reports, giving you a ballpark number of users logged in and active. This is
        # not meant to be a dead accurate representation of a users logged in state, since there is really no real way to do this with web based apps.
        # Think about a user that logs in and doesn't log out. There is no action that tells you that the user isn't technically still logged in and
        # active.
        #
        # That being said, you can use that feature to require a new login if their session timesout. Similar to how financial sites work. Just set this option to
        # true and if your record returns true for stale? then they will be required to log back in.
        #
        # Lastly, UserSession.find will still return a object is the session is stale, but you will not get a record. This allows you to determine if the
        # user needs to log back in because their session went stale, or because they just aren't logged in. Just call current_user_session.stale? as your flag.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def logout_on_timeout(value = nil)
          if value.nil?
            read_inheritable_attribute(:logout_on_timeout) || logout_on_timeout(false)
          else
            write_inheritable_attribute(:logout_on_timeout, value)
          end
        end
        alias_method :logout_on_timeout=, :logout_on_timeout
        
        # To help protect from brute force attacks you can set a limit on the allowed number of consecutive failed logins. By default this is 50, this is a very liberal
        # number, and if someone fails to login after 50 tries it should be pretty obvious that it's a machine trying to login in and very likely a brute force attack.
        #
        # In order to enable this field your model MUST have a failed_login_count (integer) field.
        #
        # If you don't know what a brute force attack is, it's when a machine tries to login into a system using every combination of character possible. Thus resulting
        # in possibly millions of attempts to log into an account.
        #
        # * <tt>Default:</tt> 50
        # * <tt>Accepts:</tt> Integer, set to 0 to disable
        def consecutive_failed_logins_limit(value = nil)
          if value.nil?
            read_inheritable_attribute(:consecutive_failed_logins_limit) || consecutive_failed_logins_limit(50)
          else
            write_inheritable_attribute(:consecutive_failed_logins_limit, value)
          end
        end
        alias_method :consecutive_failed_logins_limit=, :consecutive_failed_logins_limit
        
        def not_active_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :not_active_message=, :not_active_message
        
        def not_approved_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :not_approved_message=, :not_approved_message
        
        def not_confirmed_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :not_confirmed_message=, :not_confirmed_message
        
        # Works exactly like cookie_key, but for params. So a user can login via params just like a cookie or a session. Your URL would look like:
        #
        #   http://www.domain.com?user_credentials=my_single_access_key
        #
        # You can change the "user_credentials" key above with this configuration option. Keep in mind, just like cookie_key, if you supply an id
        # the id will be appended to the front. Check out cookie_key for more details. Also checkout the "Single Access / Private Feeds Access" section in the README.
        #
        # * <tt>Default:</tt> cookie_key
        # * <tt>Accepts:</tt> String
        def params_key(value = nil)
          if value.nil?
            read_inheritable_attribute(:params_key) || params_key(cookie_key)
          else
            write_inheritable_attribute(:params_key, value)
          end
        end
        alias_method :params_key=, :params_key
        
        def password_blank_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :password_blank_message=, :password_blank_message
        
        # Works exactly like login_field, but for the password instead.
        #
        # * <tt>Default:</tt> :password
        # * <tt>Accepts:</tt> Symbol or String
        def password_field(value = nil)
          if value.nil?
            read_inheritable_attribute(:password_field) || password_field(:password)
          else
            write_inheritable_attribute(:password_field, value)
          end
        end
        alias_method :password_field=, :password_field
        
        def password_invalid_message(value = nil) # :nodoc:
          new_i18n_error
        end
        alias_method :password_invalid_message=, :password_invalid_message
        
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
        
        # Authentication is allowed via a single access token, but maybe this is something you don't want for your application as a whole. Maybe this is something you only want for specific request types.
        # Specify a list of allowed request types and single access authentication will only be allowed for the ones you specify. Checkout the "Single Access / Private Feeds Access" section in the README.
        #
        # * <tt>Default:</tt> "application/rss+xml", "application/atom+xml"
        # * <tt>Accepts:</tt> String of request type, or :all to allow single access authentication for any and all request types
        def single_access_allowed_request_types(*values)
          if values.blank?
            read_inheritable_attribute(:single_access_allowed_request_types) || single_access_allowed_request_types("application/rss+xml", "application/atom+xml")
          else
            write_inheritable_attribute(:single_access_allowed_request_types, values)
          end
        end
        alias_method :single_access_allowed_request_types=, :single_access_allowed_request_types
        
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
        
        private
          def new_i18n_error
            raise NotImplementedError.new("As of v 1.4.0 Authlogic implements a new I18n solution that is much cleaner and easier. Please see Authlogic::I18n for more information on how to provide internationalization in Authlogic.")
          end
      end
      
      module InstanceMethods # :nodoc:
        def change_single_access_token_with_password?
          self.class.change_single_access_token_with_password == true
        end
        
        def consecutive_failed_logins_limit
          self.class.consecutive_failed_logins_limit
        end
        
        def cookie_key
          build_key(self.class.cookie_key)
        end
        
        def disable_magic_states?
          self.class.disable_magic_states == true
        end
        
        def find_by_login_method
          self.class.find_by_login_method
        end
        
        def find_with
          self.class.find_with
        end
        
        def last_request_at_threshold
          self.class.last_request_at_threshold
        end
      
        def login_field
          self.class.login_field
        end
        
        def logout_on_timeout?
          self.class.logout_on_timeout == true
        end
        
        def params_allowed_request_types
          build_key(self.class.params_allowed_request_types)
        end
        
        def params_key
          build_key(self.class.params_key)
        end
      
        def password_field
          self.class.password_field
        end
        
        def perishable_token_field
          klass.acts_as_authentic_config[:perishable_token_field]
        end
        
        def remember_me_for
          return unless remember_me?
          self.class.remember_me_for
        end
        
        def persistence_token_field
          klass.acts_as_authentic_config[:persistence_token_field]
        end
        
        def session_key
          build_key(self.class.session_key)
        end
        
        def single_access_token_field
          klass.acts_as_authentic_config[:single_access_token_field]
        end
        
        def single_access_allowed_request_types
          self.class.single_access_allowed_request_types
        end
      
        def verify_password_method
          self.class.verify_password_method
        end
        
        private
          def build_key(last_part)
            key_parts = [id, scope[:id], last_part].compact
            key_parts.join("_")
          end
      end
    end
  end
end