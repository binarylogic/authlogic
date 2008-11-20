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
        # === Options
        #
        # * <tt>session_class</tt> - default: "#{name}Session",
        #   This is the related session class. A lot of the configuration will be based off of the configuration values of this class.
        #   
        # * <tt>crypto_provider</tt> - default: Authlogic::CryptoProviders::Sha512,
        #   This is the class that provides your encryption. By default Authlogic provides its own crypto provider that uses Sha512 encrypton.
        #
        # * <tt>validate_fields</tt> - default: true,
        #   Tells Authlogic if it should validate ANY of the fields: login_field, email_field, and password_field. If set to false, no validations will be set for any of these fields.
        #
        # * <tt>login_field</tt> - default: :login, :username, or :email, depending on which column is present, if none are present defaults to :login
        #   The name of the field used for logging in. Only specify if you aren't using any of the defaults.
        #   
        # * <tt>login_field_type</tt> - default: options[:login_field] == :email ? :email : :login,
        #   Tells authlogic how to validation the field, what regex to use, etc. If the field name is email it will automatically use :email,
        #   otherwise it uses :login.
        #
        # * <tt>validate_login_field</tt> - default: true,
        #   Tells authlogic if it should validate the :login_field. If set to false, no validations will be set for this field at all.
        #   
        # * <tt>login_field_regex</tt> - default: if :login_field_type is :email then typical email regex, otherwise typical login regex.
        #   This is used in validates_format_of for the :login_field.
        #   
        # * <tt>login_field_regex_failed_message</tt> - the message to use when the validates_format_of for the login field fails. This depends on if you are
        #   performing :email or :login regex.
        #
        # * <tt>allow_blank_login_and_password_fields</tt> - default: false,
        #   Tells authlogic if it should allow blank values for the login and password. This is useful is you provide alternate authentication methods, such as OpenID.
        #
        # * <tt>email_field</tt> - default: :email, depending on if it is present, if :email is not present defaults to nil
        #   The name of the field used to store the email address. Only specify this if you arent using this as your :login_field.
        #   
        # * <tt>validate_email_field</tt> - default: true,
        #   Tells Authlogic if it should validate the email field. If set to false, no validations will be set for this field at all.
        #
        # * <tt>email_field_regex</tt> - default: type email regex
        #   This is used in validates_format_of for the :email_field.
        #   
        # * <tt>email_field_regex_failed_message</tt> - the message to use when the validates_format_of for the email field fails.
        #
        # * <tt>allow_blank_email_field</tt> - default: false,
        #   Tells Authlogic if it should allow blank values for the email address.
        #   
        # * <tt>change_single_access_token_with_password</tt> - default: false,
        #   When a user changes their password do you want the single access token to change as well? That's what this configuration option is all about.
        #
        # * <tt>single_access_token_field</tt> - default: :single_access_token, :feed_token, or :feeds_token, depending on which column is present, if none are present defaults to nil
        #   This is the name of the field to login with single access, mainly used for private feed access. Only specify if the name of the field is different
        #   then the defaults. See the "Single Access" section in the README for more details on how single access works.
        #
        # * <tt>password_field</tt> - default: :password,
        #   This is the name of the field to set the password, *NOT* the field the encrypted password is stored. Defaults the what the configuration
        #
        # * <tt>validate_password_field</tt> - default: :password,
        #   Tells authlogic if it should validate the :password_field. If set to false, no validations will be set for this field at all.
        #
        # * <tt>password_blank_message</tt> - default: "can not be blank",
        #   The error message used when the password is left blank.
        #
        # * <tt>confirm_password_did_not_match_message</tt> - default: "did not match",
        #   The error message used when the confirm password does not match the password
        #
        # * <tt>crypted_password_field</tt> - default: :crypted_password, :encrypted_password, :password_hash, :pw_hash, depends on which columns are present, if none are present defaults to nil
        #   The name of the database field where your encrypted password is stored.
        #
        # * <tt>password_salt_field</tt> - default: :password_salt, :pw_salt, or :salt, depending on which column is present, defaults to :password_salt if none are present,
        #   This is the name of the field in your database that stores your password salt.
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
        # * <tt>persistence_field</tt> - default: :persistence_token, :remember_token, or :cookie_tokien, depending on which column is present,
        #   defaults to :persistence_token if none are present,
        #   This is the name of the field your persistence token is stored. The persistence token is a unique token that is stored in the users cookie and
        #   session. This way you have complete control of when sessions expire and you don't have to change passwords to expire sessions. This also
        #   ensures that stale sessions can not be persisted. By stale, I mean sessions that are logged in using an outdated password.
        #   
        # * <tt>scope</tt> - default: nil,
        #   This scopes validations. If all of your users belong to an account you might want to scope everything to the account. Just pass :account_id
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
        module Config
          def first_column_to_exist(*columns_to_check) # :nodoc:
            columns_to_check.each { |column_name| return column_name.to_sym if column_names.include?(column_name.to_s) }
            columns_to_check.first ? columns_to_check.first.to_sym : nil
          end
        
          def acts_as_authentic_with_config(options = {})
            # Stop all configuration if the DB is not set up
            begin
              column_names
            rescue Exception
              return
            end
            
            options[:session_class] ||= "#{name}Session"
            options[:crypto_provider] ||= CryptoProviders::Sha512
            options[:validate_fields] = true unless options.key?(:validate_fields)
            options[:login_field] ||= first_column_to_exist(:login, :username, :email)
            options[:login_field_type] ||= options[:login_field] == :email ? :email : :login
            options[:validate_login_field] = true unless options.key?(:validate_login_field)
            options[:email_field] = first_column_to_exist(nil, :email) unless options.key?(:email_field)
            options[:email_field] = nil if options[:email_field] == options[:login_field]
            options[:validate_email_field] = true unless options.key?(:validate_email_field)
            options[:allow_blank_login_and_password]
            
            email_name_regex  = '[\w\.%\+\-]+'
            domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
            domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
            options[:email_field_regex] ||= /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
            options[:email_field_regex_failed_message] ||= "should look like an email address."
            
            case options[:login_field_type]
            when :email
              options[:login_field_regex] ||= options[:email_field_regex]
              options[:login_field_regex_failed_message] ||= options[:email_field_regex_failed_message]
            else
              options[:login_field_regex] ||= /\A\w[\w\.\-_@ ]+\z/
              options[:login_field_regex_failed_message] ||= "should use only letters, numbers, spaces, and .-_@ please."
            end
          
            options[:password_field] ||= :password
            options[:validate_password_field] = true unless options.key?(:validate_password_field)
            
            options[:password_blank_message] ||= "can not be blank"
            options[:confirm_password_did_not_match_message] ||= "did not match"
            options[:crypted_password_field] ||= first_column_to_exist(:crypted_password, :encrypted_password, :password_hash, :pw_hash)
            options[:password_salt_field] ||= first_column_to_exist(:password_salt, :pw_salt, :salt)
            options[:persistence_token_field] ||= options[:remember_token_field] || first_column_to_exist(:persistence_token, :remember_token, :cookie_token)
            options[:single_access_token_field] ||= first_column_to_exist(nil, :single_access_token, :feed_token, :feeds_token)
            options[:perishable_token_field] ||= options[:password_reset_token_field] || first_column_to_exist(nil, :perishable_token, :password_reset_token, :pw_reset_token, :reset_password_token, :reset_pw_token, :activation_token)
            options[:perishable_token_valid_for] ||= 10.minutes
            options[:perishable_token_valid_for] = options[:perishable_token_valid_for].to_i
            options[:logged_in_timeout] ||= 10.minutes
            options[:logged_in_timeout] = options[:logged_in_timeout].to_i
            options[:session_ids] ||= [nil]
          
            class_eval <<-"end_eval", __FILE__, __LINE__
              def self.acts_as_authentic_config
                #{options.inspect}
              end
            end_eval
          
            acts_as_authentic_without_config(options)
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