module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Password Reset
        #
        # Handles all logic the deals with maintaining the password reset token. This token should be used to authenticate a user that is not logged in so that they
        # can change their password.
        #
        # === Class Methods
        #
        # * <tt>find_using_{options[:password_reset_token_field]}(token)</tt> - returns the record that matches the pased token. The record's updated at column must not be older than
        #   {options[:password_reset_token_valid_for]} ago. Lastly, if a blank token is passed no record will be returned.
        #
        # === Instance Methods
        #
        # * <tt>reset_#{options[:password_reset_token_field]}</tt> - resets the password reset token field to a friendly unique token.
        # * <tt>reset_#{options[:password_reset_token_field]}!</tt> - same as above but saves the record afterwards.
        module PasswordReset
          def acts_as_authentic_with_password_reset(options = {})
            acts_as_authentic_without_password_reset(options)
            
            return if options[:password_reset_token_field].blank?
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              validates_uniqueness_of :#{options[:password_reset_token_field]}
              
              before_validation :reset_#{options[:password_reset_token_field]}, :unless => :resetting_#{options[:password_reset_token_field]}?
              
              def self.find_using_#{options[:password_reset_token_field]}(token)
                return if token.blank?
                
                conditions_sql = "#{options[:password_reset_token_field]} = ?"
                conditions_subs = [token]
                
                if column_names.include?("updated_at") && #{options[:password_reset_token_valid_for]} > 0
                  conditions_sql += " and updated_at > ?"
                  conditions_subs << #{options[:password_reset_token_valid_for]}.seconds.ago
                end
                
                find(:first, :conditions => [conditions_sql, *conditions_subs])
              end
              
              def reset_#{options[:password_reset_token_field]}
                self.#{options[:password_reset_token_field]} = self.class.friendly_unique_token
              end
              
              def reset_#{options[:password_reset_token_field]}!
                reset_#{options[:password_reset_token_field]}
                @resetting_#{options[:password_reset_token_field]} = true
                result = save_without_session_maintenance
                @resetting_#{options[:password_reset_token_field]} = false
                result
              end
              
              private
                def resetting_#{options[:password_reset_token_field]}?
                  @resetting_#{options[:password_reset_token_field]} == true
                end
            end_eval
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::PasswordReset
    alias_method_chain :acts_as_authentic, :password_reset
  end
end