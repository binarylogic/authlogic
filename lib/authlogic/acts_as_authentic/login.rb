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
        # * <tt>Default:</tt> {:case_sensitive => false, :scope => validations_scope, :if => "#{login_field}_changed?".to_sym}
        # * <tt>Accepts:</tt> Hash of options accepted by validates_uniqueness_of
        def validates_uniqueness_of_login_field_options(value = nil)
          config(:validates_uniqueness_of_login_field_options, value, {:case_sensitive => false, :scope => validations_scope, :if => "#{login_field}_changed?".to_sym})
        end
        alias_method :validates_uniqueness_of_login_field_options=, :validates_uniqueness_of_login_field_options
      end
      
      # All methods relating to the login field
      module Methods
        # Adds in various validations, modules, etc.
        def self.included(klass)
          klass.class_eval do
            extend ClassMethods
            
            if validate_login_field && login_field
              validates_length_of login_field, validates_length_of_login_field_options
              validates_format_of login_field, validates_format_of_login_field_options
              validates_uniqueness_of login_field, validates_uniqueness_of_login_field_options
            end
          end
        end
        
        # Class methods relating to the login field.
        module ClassMethods
          # Calls alias_method if your login_field name is "out of the norm".
          def self.included(klass)
            klass.send(:alias_method, "find_with_login", "find_with_#{login_field}") if klass.login_field != :login
          end
          
          # This method allows you to find a record with the given login. If you notice, with ActiveRecord you have the
          # validates_uniqueness_of validation function. They give you a :case_sensitive option. I handle this in the same
          # manner that they handle that. If you set false for the :case_sensitive option in validates_uniqueness_of_login_field_options
          # this method will modify the query to look something like:
          #
          #   first(:conditions => ["LOWER(#{quoted_table_name}.#{login_field}) = ?", login.downcase])
          #
          # If you don't specify this it calls the good old find_by_* method:
          #
          #   find_by_login(login)
          #
          # The only reason I need to do the above is for Postgres and SQLite since they perform case sensitive searches with the
          # find_by_* methods.
          def find_with_login(login)
            if validates_uniqueness_of_login_field_options[:case_sensitive] == false
              first(:conditions => ["LOWER(#{quoted_table_name}.#{login_field}) = ?", login.downcase])
            else
              send("find_by_#{login_field}", login)
            end
          end
        end
      end
    end
  end
end