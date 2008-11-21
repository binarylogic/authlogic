module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Single Access
        #
        # Instead of repeating myself here, checkout the README. There is a "Tokens" section in there that goes over the single access token.
        # Keep in mind none of this will be applied if there is not a single_access_token field supplied in the database.
        #
        # === Instance Methods
        #
        # * <tt>reset_{options[:single_access_token_field]}</tt> - resets the single access token with the friendly_unique_token
        # * <tt>reset_{options[:single_access_token_field]}!</tt> - same as above, but saves the record afterwards
        #
        # === Alias Method Chains
        #
        # * <tt>{options[:password_field]}</tt> - if the :change_single_access_token_with_password is set to true, reset_{options[:single_access_token_field]} will be called when the password changes
        module SingleAccess
          def acts_as_authentic_with_single_access(options = {})
            acts_as_authentic_without_single_access(options)
            
            return if options[:single_access_token_field].blank?
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              validates_uniqueness_of :#{options[:single_access_token_field]}, :if => :#{options[:single_access_token_field]}_changed?
            
              before_validation :set_#{options[:single_access_token_field]}_field
            
              def password_with_single_access=(value)
                reset_#{options[:single_access_token_field]} if #{options[:change_single_access_token_with_password].inspect}
                self.password_without_single_access = value
              end
              alias_method_chain :password=, :single_access
            
              def reset_#{options[:single_access_token_field]}
                self.#{options[:single_access_token_field]} = self.class.friendly_unique_token
              end
            
              def reset_#{options[:single_access_token_field]}!
                reset_#{options[:single_access_token_field]}
                save_without_session_maintenance
              end
            
              protected
                def set_#{options[:single_access_token_field]}_field
                  reset_#{options[:single_access_token_field]} if #{options[:single_access_token_field]}.blank?
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
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::SingleAccess
    alias_method_chain :acts_as_authentic, :single_access
  end
end