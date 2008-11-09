module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module Persistence # :nodoc:
        def acts_as_authentic_with_persistence(options = {})
          acts_as_authentic_without_persistence(options)
          
          class_eval <<-"end_eval", __FILE__, __LINE__
            def self.remember_token_field
              @remember_token_field ||= #{options[:remember_token_field].inspect} ||
              (column_names.include?("remember_token") && :remember_token) ||
              (column_names.include?("remember_key") && :remember_key) ||
              (column_names.include?("cookie_token") && :cookie_token) ||
              (column_names.include?("cookie_key") && :cookie_key) ||
              :remember_token
            end
          end_eval
          
          validates_uniqueness_of remember_token_field
          
          def unique_token
            # Force using the Sha512 because all that we are doing is creating a unique token, a hash is perfect for this
            Authlogic::Sha512CryptoProvider.encrypt(Time.now.to_s + (1..10).collect{ rand.to_s }.join)
          end
          
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
            def forget!
              self.#{remember_token_field} = self.class.unique_token
              save_without_session_maintenance(false)
            end
            
            def password_with_persistence=(value)
              self.#{remember_token_field} = self.class.unique_token
              self.password_without_persistence = value
            end
            alias_method_chain :password=, :persistence
          end_eval
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::Persistence
    alias_method_chain :acts_as_authentic, :persistence
  end
end