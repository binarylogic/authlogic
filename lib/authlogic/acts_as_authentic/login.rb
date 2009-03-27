module Authlogic
  module ActsAsAuthentic
    # Handles everything related to the login field.
    module Login
      def self.included(klass)
        klass.class_eval do
          extend Config
          add_acts_as_authentic_module(Methods)
        end
      end
      
      # Confguration for the login field.
      module Config
        # The name of the login field in the database.
        #
        # * <tt>Default:</tt> :login or :username, if they exist
        # * <tt>Accepts:</tt> Symbol
        def login_field(value = nil)
          config(:login_field, value, first_column_to_exist(nil, :login, :username))
        end
        alias_method :login_field=, :login_field
        
        # Whether or not the validate the login field
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def validate_login_field(value = nil)
          config(:validate_login_field, value, true)
        end
        alias_method :validate_login_field=, :validate_login_field
        
        # A hash of options for the validates_length_of call for the login field. Allows you to change this however you want.
        #
        # * <tt>Default:</tt> {:within => 6..100}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_length_of
        def validates_length_of_login_field_options(value = nil)
          config(:validates_length_of_login_field_options, value, {:within => 3..100})
        end
        alias_method :validates_length_of_login_field_options=, :validates_length_of_login_field_options
        
        # A hash of options for the validates_format_of call for the login field. Allows you to change this however you want.
        #
        # * <tt>Default:</tt> {:with => /\A\w[\w\.\-_@ ]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please.")}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_format_of
        def validates_format_of_login_field_options(value = nil)
          config(:validates_format_of_login_field_options, value, {:with => /\A\w[\w\.\-_@ ]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please.")})
        end
        alias_method :validates_format_of_login_field_options=, :validates_format_of_login_field_options
        
        # A hash of options for the validates_uniqueness_of call for the login field. Allows you to change this however you want.
        #
        # * <tt>Default:</tt> {:scope => validations_scope, :if => "#{login_field}_changed?".to_sym}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_uniqueness_of
        def validates_uniqueness_of_login_field_options(value = nil)
          config(:validates_uniqueness_of_login_field_options, value, {:scope => validations_scope, :if => "#{login_field}_changed?".to_sym})
        end
        alias_method :validates_uniqueness_of_login_field_options=, :validates_uniqueness_of_login_field_options
      end
      
      # All methods relating to the login field
      module Methods
        def self.included(klass)
          klass.class_eval do
            if validate_login_field && login_field
              validates_length_of login_field, validates_length_of_login_field_options
              validates_format_of login_field, validates_format_of_login_field_options
              validates_uniqueness_of login_field, validates_uniqueness_of_login_field_options
            end
          end
        end
      end
    end
  end
end