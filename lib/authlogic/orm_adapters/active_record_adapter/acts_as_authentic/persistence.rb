module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Persistence
        #
        # This is responsible for all record persistence. Basically what your Authlogic session needs to persist the record's session.
        #
        # === Class Methods
        #
        # * <tt>forget_all!</tt> - resets ALL records persistence_token to a unique value, requiring all users to re-login
        # * <tt>unique_token</tt> - returns a pretty hardcore random token that is finally encrypted with a hash algorithm
        #
        # === Instance Methods
        #
        # * <tt>forget!</tt> - resets the record's persistence_token which requires them to re-login
        #
        # === Alias Method Chains
        #
        # * <tt>#{options[:password_field]}</tt> - adds in functionality to reset the persistence token when the password is changed
        module Persistence
          def acts_as_authentic_with_persistence(options = {})
            acts_as_authentic_without_persistence(options)
          
            validates_presence_of options[:persistence_token_field]
            validates_uniqueness_of options[:persistence_token_field], :if => "#{options[:persistence_token_field]}_changed?".to_sym
            
            before_validation "reset_#{options[:persistence_token_field]}".to_sym, :if => "reset_#{options[:persistence_token_field]}?".to_sym
          
            def forget_all!
              # Paginate these to save on memory
              records = nil
              i = 0
              begin
                records = find(:all, :limit => 50, :offset => i)
                records.each { |record| record.forget! }
                i += 50
              end while !records.blank?
            end
          
            class_eval <<-"end_eval", __FILE__, __LINE__
              def self.unique_token
                Authlogic::Random.hex_token
              end
            
              def forget!
                self.#{options[:persistence_token_field]} = self.class.unique_token
                save_without_session_maintenance(false)
              end
            
              def #{options[:password_field]}_with_persistence=(value)
                reset_#{options[:persistence_token_field]} unless value.blank?
                self.#{options[:password_field]}_without_persistence = value
              end
              alias_method_chain :#{options[:password_field]}=, :persistence
              
              def reset_#{options[:persistence_token_field]}
                self.#{options[:persistence_token_field]} = self.class.unique_token
              end
              
              def reset_#{options[:persistence_token_field]}!
                reset_#{options[:persistence_token_field]}
                save_without_session_maintenance(false)
              end
              
              def reset_#{options[:persistence_token_field]}?
                #{options[:persistence_token_field]}.blank?
              end
              
              # When a user logs in we need to ensure they have a persistence token. Think about apps that are transitioning and
              # never have a persistence token to begin with. When their users log in their persistence token needs to be set.
              # The only other time persistence tokens are reset is in a before_validation on the user, and when a user is saved
              # from the session we skip validation for performance reasons. We do save_without_session_maintenance(false), the false
              # indicates to skip validation.
              def valid_#{options[:password_field]}_with_persistence?(attempted_password)
                result = valid_password_without_persistence?(attempted_password)
                reset_#{options[:persistence_token_field]}! if result && #{options[:persistence_token_field]}.blank?
                result
              end
              alias_method_chain :valid_#{options[:password_field]}?, :persistence
            end_eval
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::Persistence
    alias_method_chain :acts_as_authentic, :persistence
  end
end