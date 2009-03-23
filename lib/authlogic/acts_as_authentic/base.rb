module Authlogic
  module ActsAsAuthentic
    # Adds in the acts_as_authentic method to ActiveRecord.
    module Base
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end
      
      module Config
        # This includes a lot of helpful methods for authenticating records which The Authlogic::Session module relies on.
        # To use it just do:
        #
        #   class User < ActiveRecord::Base
        #     acts_as_authentic
        #   end
        #
        # Configuration is easy:
        #
        #   acts_as_authentic do |c|
        #     c.my_configuration_option = my_value
        #   end
        #
        # See the various sub modules for the configuration they provide.
        def acts_as_authentic(&block)
          yield self if block_given?
          acts_as_authentic_modules.each { |mod| include mod }
        end
      
        def add_acts_as_authentic_module(mod)
          modules = acts_as_authentic_modules
          modules << mod
          modules.uniq!
          write_inheritable_attribute(:acts_as_authentic_modules, modules)
        end
      
        def remove_acts_as_authentic_module(mod)
          acts_as_authentic_modules.delete(mod)
          acts_as_authentic_modules
        end
      
        private
          def acts_as_authentic_modules
            key = :acts_as_authentic_modules
            inheritable_attributes.include?(key) ? read_inheritable_attribute(key) : []
          end
        
          def config(key, value, default_value = nil, read_value = nil)
            if value == read_value
              return read_inheritable_attribute(key) if inheritable_attributes.include?(key)
              write_inheritable_attribute(key, default_value)
            else
              write_inheritable_attribute(key, value)
            end
          end

          def first_column_to_exist(*columns_to_check) # :nodoc:
            columns_to_check.each { |column_name| return column_name.to_sym if column_names.include?(column_name.to_s) }
            columns_to_check.first ? columns_to_check.first.to_sym : nil
          end
      end
    end
  end
end

if defined?(::ActiveRecord)
  module ::ActiveRecord
    class Base
      include Authlogic::ActsAsAuthentic::Base
      include Authlogic::ActsAsAuthentic::Email
      include Authlogic::ActsAsAuthentic::LoggedInStatus
      include Authlogic::ActsAsAuthentic::Login
      include Authlogic::ActsAsAuthentic::MagicColumns
      include Authlogic::ActsAsAuthentic::Password
      include Authlogic::ActsAsAuthentic::PerishableToken
      include Authlogic::ActsAsAuthentic::PersistenceToken
      include Authlogic::ActsAsAuthentic::RestfulAuthentication
      include Authlogic::ActsAsAuthentic::SessionMaintenance
      include Authlogic::ActsAsAuthentic::SingleAccessToken
      include Authlogic::ActsAsAuthentic::ValidationsScope
    end
  end
end