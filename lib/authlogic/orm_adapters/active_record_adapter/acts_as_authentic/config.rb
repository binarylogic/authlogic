module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Config
        #
        # Allows you to set various configuration when calling acts_as_authentic. Pass your configuration like the following:
        #
        #   class User < ActiveRecord::Base
        #     acts_as_authentic :my_option => "my value"
        #   end
        #
        # === Class Methods
        #
        # * <tt>acts_as_authentic_config</tt> - returns a hash of the acts_as_authentic configuration, including the defaults
        #
        # === General Options
        #
        # * <tt>session_class</tt> - default: "#{name}Session",
        #   This is the related session class. A lot of the configuration will be based off of the configuration values of this class.
        #   
        # * <tt>crypto_provider</tt> - default: Authlogic::CryptoProviders::Sha512,
        #   This is the class that provides your encryption. By default Authlogic provides its own crypto provider that uses Sha512 encrypton.
        #
        # * <tt>transition_from_crypto_provider</tt> - default: nil,
        #   This will transition your users to a new encryption algorithm. Let's say you are using Sha1 and you want to transition to Sha512. Just set the
        #   :crypto_provider option to Authlogic::CryptoProviders::Sha512 and then set this option to Authlogic::CryptoProviders::Sha1. Every time a user
        #   logs in their password will be resaved with the new algorithm and all new registrations will use the new algorithm as well.
        #
        # * <tt>act_like_restful_authentication</tt> - default: false,
        #   If you are migrating from restful_authentication you will want to set this to true, this way your users will still be able to log in and it will seems as
        #   if nothing has changed. If you don't do this none of your users will be able to log in. If you are starting a new project I do not recommend enabling this
        #   as the password encryption algorithm used in restful_authentication (Sha1) is not as secure as the one used in authlogic (Sha512). IF you REALLY want to be secure
        #   checkout Authlogic::CryptoProviders::BCrypt.
        #
        # * <tt>transition_from_restful_authentication</tt> - default: false,
        #   This works just like :transition_from_crypto_provider, but it makes some special exceptions so that your users will transition from restful_authentication, since
        #   restful_authentication does things a little different than Authlogic.
        #
        # * <tt>login_field</tt> - default: :login, :username, or :email, depending on which column is present, if none are present defaults to :login
        #   The name of the field used for logging in. Only specify if you aren't using any of the defaults.
        #   
        # * <tt>login_field_type</tt> - default: options[:login_field] == :email ? :email : :login,
        #   Tells authlogic how to validation the field, what regex to use, etc. If the field name is email it will automatically use :email,
        #   otherwise it uses :login.
        #
        # * <tt>password_field</tt> - default: :password,
        #   This is the name of the field to set the password, *NOT* the field the encrypted password is stored. Defaults the what the configuration
        #
        # * <tt>crypted_password_field</tt> - default: :crypted_password, :encrypted_password, :password_hash, :pw_hash, depends on which columns are present, if none are present defaults to nil
        #   The name of the database field where your encrypted password is stored.
        #
        # * <tt>password_salt_field</tt> - default: :password_salt, :pw_salt, or :salt, depending on which column is present, defaults to :password_salt if none are present,
        #   This is the name of the field in your database that stores your password salt.
        #
        # * <tt>email_field</tt> - default: :email, depending on if it is present, if :email is not present defaults to nil
        #   The name of the field used to store the email address. Only specify this if you arent using this as your :login_field.
        #
        # * <tt>single_access_token_field</tt> - default: :single_access_token, :feed_token, or :feeds_token, depending on which column is present, if none are present defaults to nil
        #   This is the name of the field to login with single access, mainly used for private feed access. Only specify if the name of the field is different
        #   then the defaults. See the "Single Access" section in the README for more details on how single access works.
        #
        # * <tt>change_single_access_token_with_password</tt> - default: false,
        #   When a user changes their password do you want the single access token to change as well? That's what this configuration option is all about.
        #
        # * <tt>perishable_token_field</tt> - default: :perishable_token, :password_reset_token, :pw_reset_token, :reset_password_token, or :reset_pw_token, depending on which column is present, if none are present defaults to nil
        #   This is the name of the field in your database that stores your perishable token. The token you should use to confirm your users or allow a password reset. Authlogic takes care
        #   of maintaining this for you and making sure it changes when needed. Use this token for whatever you want, but keep in mind it is temporary, hence the term "perishable".
        #
        # * <tt>perishable_token_valid_for</tt> - default: 10.minutes,
        #   Authlogic gives you a sepcial method for finding records by the perishable token (see Authlogic::ORMAdapters::ActiveRecordAdapter::ActcsAsAuthentic::Perishability). In this method
        #   it checks for the age of the token. If the token is older than whatever you specify here, a record will NOT be returned. This way the tokens are perishable, thus making this system much
        #   more secure.
        #
        # * <tt>disable_perishble_token_maintenance</tt> - default: false,
        #   Authlogic automatically maintains when to reset the perishable_token. This token should reset frequently because it is "perishable", but how frequent depends on your app.
        #   By default it tries to reset this token as much as possible, which is done via a before_validation callback. If for some reason you want to maintain this yourself just
        #   set this to true and use the reset_perishable_token and reset_perishable_token! methods to maintain it yourself.
        #   
        # * <tt>persistence_token_field</tt> - default: :persistence_token, :remember_token, or :cookie_tokien, depending on which column is present,
        #   defaults to :persistence_token if none are present,
        #   This is the name of the field your persistence token is stored. The persistence token is a unique token that is stored in the users cookie and
        #   session. This way you have complete control of when sessions expire and you don't have to change passwords to expire sessions. This also
        #   ensures that stale sessions can not be persisted. By stale, I mean sessions that are logged in using an outdated password.
        #   
        # * <tt>logged_in_timeout</tt> - default: 10.minutes,
        #   This is a nifty feature to tell if a user is logged in or not. It's based on activity. So if the user in inactive longer than
        #   the value passed here they are assumed "logged out". This uses the last_request_at field, this field must be present for this option to take effect.
        #   
        # * <tt>session_ids</tt> - default: [nil],
        #   The sessions that we want to automatically reset when a user is created or updated so you don't have to worry about this. Set to [] to disable.
        #   Should be an array of ids. See the Authlogic::Session documentation for information on ids. The order is important.
        #   The first id should be your main session, the session they need to log into first. This is generally nil. When you don't specify an id
        #   in your session you are really just inexplicitly saying you want to use the id of nil.
        #
        # === Validation Options
        #
        # * <tt>validate_fields</tt> - default: true,
        #   Tells Authlogic if it should validate ANY of the fields: login_field, email_field, and password_field. If set to false, no validations will be set for any of these fields.
        #
        # * <tt>validate_login_field</tt> - default: true,
        #   Tells authlogic if it should validate the :login_field. If set to false, no validations will be set for this field at all.
        #
        # * <tt>validate_email_field</tt> - default: true,
        #   Tells Authlogic if it should validate the email field. If set to false, no validations will be set for this field at all.
        #
        # * <tt>validate_password_field</tt> - default: :password,
        #   Tells authlogic if it should validate the :password_field. If set to false, no validations will be set for this field at all.
        #
        # * <tt>scope</tt> - default: nil,
        #   This scopes validations. If all of your users belong to an account you might want to scope everything to the account. Just pass :account_id
        #
        # * <tt>validation_options</tt> - default: {},
        #   Options to pass to ALL validations. These are the options ActiveRecord supplies with their validation methods, see the ActiveRecord documentation for more details.
        #
        # * <tt>login_field_validation_options</tt> - default: {},
        #   The same as :validation_options but these are only applied to validations that pertain to the :login_field
        #
        # * <tt>login_field_validates_length_of_options</tt> - default: :login_field_type == :email ? {:within => 6..100} : {:within => 2..100},
        #   These options are applied to the validates_length_of call for the :login_field
        #
        # * <tt>login_field_validates_format_of_options</tt> - default: :login_field_type == :email ? {:with => standard_email_regex, :message => "should look like an email address."} : {:with => standard_login_regex, :message => "should use only letters, numbers, spaces, and .-_@ please."},
        #   These options are applied to the validates_format_of call for the :login_field
        #
        # * <tt>login_field_validates_uniqueness_of_options</tt> - default: {:allow_blank => true},
        #   These options are applied to the validates_uniqueness_of call for the :login_field, the :allow_blank => true just prevents the error message when you have options login fields
        #   such as an OpenID field. The other validations will make sure the field is not actaully blank.
        #
        # * <tt>password_field_validation_options</tt> - default: {},
        #   The same as :validation_options but these are only applied to validations that pertain to the :password_field
        #
        # * <tt>password_field_validates_length_of_options</tt> - default: {:minimum => 4},
        #   These options are applied to the validates_length_of call for the :password_field
        #
        # * <tt>password_field_validates_confirmation_of_options</tt> - default: {},
        #   These options are applied to the validates_confirmation_of call for the :password_field
        #
        # * <tt>password_confirmation_field_validates_presence_of_options</tt> - default: {},
        #   These options are applied to the validates_presence_of call for the :password_confirmation_field.
        #
        # * <tt>email_field_validation_options</tt> - default: {},
        #   The same as :validation_options but these are only applied to validations that pertain to the :email_field
        #
        # * <tt>email_field_validates_length_of_options</tt> - default: same as :login_field if :login_field_type == :email,
        #   These options are applied to the validates_length_of call for the :email_field
        #
        # * <tt>email_field_validates_format_of_options</tt> - default: same as :login_field if :login_field_type == :email,
        #   These options are applied to the validates_format_of call for the :email_field
        #
        # * <tt>email_field_validates_uniqueness_of_options</tt> - default: same as :login_field if :login_field_type == :email,
        #   These options are applied to the validates_uniqueness_of call for the :email_field
        module Config
          def acts_as_authentic_with_config(options = {})
            # Stop all configuration if the DB is not set up
            begin
              column_names
            rescue Exception
              return
            end
            
            # Base configuration
            options[:session_class] ||= "#{name}Session"
            options[:crypto_provider] ||= CryptoProviders::Sha512
            options[:login_field] ||= first_column_to_exist(:login, :username, :email)
            options[:login_field_type] ||= options[:login_field] == :email ? :email : :login
            options[:password_field] ||= :password
            options[:crypted_password_field] ||= first_column_to_exist(:crypted_password, :encrypted_password, :password_hash, :pw_hash)
            options[:password_salt_field] ||= first_column_to_exist(:password_salt, :pw_salt, :salt)
            
            options[:email_field] = first_column_to_exist(nil, :email) unless options.key?(:email_field)
            options[:email_field] = nil if options[:email_field] == options[:login_field]
            options[:persistence_token_field] ||= options[:remember_token_field] || first_column_to_exist(:persistence_token, :remember_token, :cookie_token)
            options[:single_access_token_field] ||= first_column_to_exist(nil, :single_access_token, :feed_token, :feeds_token)
            options[:perishable_token_field] ||= options[:password_reset_token_field] || first_column_to_exist(nil, :perishable_token, :password_reset_token, :pw_reset_token, :reset_password_token, :reset_pw_token, :activation_token)
            options[:perishable_token_valid_for] ||= 10.minutes
            options[:perishable_token_valid_for] = options[:perishable_token_valid_for].to_i
            options[:logged_in_timeout] ||= 10.minutes
            options[:logged_in_timeout] = options[:logged_in_timeout].to_i
            options[:session_ids] ||= [nil]
            
            # Validation configuration
            options[:validate_fields] = true unless options.key?(:validate_fields)
            options[:validate_login_field] = true unless options.key?(:validate_login_field)
            options[:validate_password_field] = true unless options.key?(:validate_password_field)
            options[:validate_email_field] = true unless options.key?(:validate_email_field)
            
            options[:validation_options] ||= {}
            
            [:login, :password, :email].each do |field_name|
              field_key = "#{field_name}_field_validation_options".to_sym
              options[field_key] = options[:validation_options].merge(options[field_key] || {})
              
              validation_types = field_name == :password ? [:length, :confirmation] : [:length, :format, :uniqueness]
              validation_types.each do |validation_type|
                validation_key = "#{field_name}_field_validates_#{validation_type}_of_options".to_sym
                options[validation_key] = options[field_key].merge(options[validation_key] || {})
              end
            end
            
            options[:password_confirmation_field_validates_presence_of_options] ||= {}
            
            if options[:scope]
              options[:login_field_validates_uniqueness_of_options][:scope] ||= options[:scope]
              options[:email_field_validates_uniqueness_of_options][:scope] ||= options[:scope]
            end
            
            if options[:act_like_restful_authentication] || options[:transition_from_restful_authentication]
              crypto_provider_key = options[:act_like_restful_authentication] ? :crypto_provider : :transition_from_crypto_provider
              options[crypto_provider_key] = CryptoProviders::Sha1
              if !defined?(REST_AUTH_SITE_KEY) || REST_AUTH_SITE_KEY.nil?
                class_eval("::REST_AUTH_SITE_KEY = nil") unless defined?(REST_AUTH_SITE_KEY)
                options[crypto_provider_key].stretches = 1
              end
            end
            
            options[:transition_from_crypto_provider] = [options[:transition_from_crypto_provider]].compact unless options[:transition_from_crypto_provider].is_a?(Array)
            
            cattr_accessor :acts_as_authentic_config
            self.acts_as_authentic_config = options
            acts_as_authentic_without_config(options)
          end
          
          def first_column_to_exist(*columns_to_check) # :nodoc:
            columns_to_check.each { |column_name| return column_name.to_sym if column_names.include?(column_name.to_s) }
            columns_to_check.first ? columns_to_check.first.to_sym : nil
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::Config
    alias_method_chain :acts_as_authentic, :config
  end
end