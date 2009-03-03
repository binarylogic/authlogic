module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Perishable
        #
        # Handles all logic the deals with maintaining the perishable token. This token should be used to authenticate a user that is not logged in so that they
        # can change their password, confirm their account, etc. Use it for whatever you want, but keep in mind this token is only temporary. Which
        # is perfect for emailing, etc.
        #
        # === Class Methods
        #
        # * <tt>find_using_{options[:perishable_token_field]}(token, age = {options[:perishable_token_valid_for]})</tt> - returns the record that matches the pased token. The record's updated at column must not be older than
        #   {age} ago. Lastly, if a blank token is passed no record will be returned.
        #
        # === Instance Methods
        #
        # * <tt>reset_#{options[:perishable_token_field]}</tt> - resets the perishable token field to a friendly unique token.
        # * <tt>reset_#{options[:perishable_token_field]}!</tt> - same as above but saves the record afterwards.
        module Perishability
          def acts_as_authentic_with_perishability(options = {})
            acts_as_authentic_without_perishability(options)
            
            return if options[:perishable_token_field].blank?
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              validates_uniqueness_of :#{options[:perishable_token_field]}, :if => :#{options[:perishable_token_field]}_changed?
              
              before_save :reset_#{options[:perishable_token_field]}, :unless => :disable_#{options[:perishable_token_field]}_maintenance?
              
              def self.find_using_#{options[:perishable_token_field]}(token, age = #{options[:perishable_token_valid_for]})
                return if token.blank?
                age = age.to_i
                
                conditions_sql = "#{options[:perishable_token_field]} = ?"
                conditions_subs = [token]
                
                if column_names.include?("updated_at") && age > 0
                  conditions_sql += " and updated_at > ?"
                  conditions_subs << age.seconds.ago
                end
                
                find(:first, :conditions => [conditions_sql, *conditions_subs])
              end
              
              def reset_#{options[:perishable_token_field]}
                self.#{options[:perishable_token_field]} = self.class.friendly_unique_token
              end
              
              def reset_#{options[:perishable_token_field]}!
                reset_#{options[:perishable_token_field]}
                save_without_session_maintenance(false)
              end
              
              def disable_#{options[:perishable_token_field]}_maintenance?
                #{options[:disable_perishable_token_maintenance].inspect} == true
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
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::Perishability
    alias_method_chain :acts_as_authentic, :perishability
  end
end