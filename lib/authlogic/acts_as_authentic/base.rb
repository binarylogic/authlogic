module Authlogic
  module ActsAsAuthentic
    # Provides the base functionality for acts_as_authentic
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
        def acts_as_authentic(unsupported_options = nil, &block)
          # Stop all configuration if the DB is not set up
          begin
            column_names
          rescue Exception
            return
          end
          
          raise ArgumentError.new("You are using the old v1.X.X configuration method for Authlogic. Instead of " +
            "passing a hash of configuration options to acts_as_authentic, pass a block: acts_as_authentic { |c| c.my_option = my_value }") if !unsupported_options.nil?
          
          yield self if block_given?
          acts_as_authentic_modules.each { |mod| include mod }
        end
        
        # Since this part of Authlogic deals with another class, ActiveRecord, we can't just start including things
        # in ActiveRecord itself. A lot of these module includes need to be triggered by the acts_as_authentic method
        # call. For example, you don't want to start adding in email validations and what not into a model that has
        # nothing to do with Authlogic.
        #
        # That being said, this is your tool for extending Authlogic and "hooking" into the acts_as_authentic call.
        def add_acts_as_authentic_module(mod, action = :append)
          modules = acts_as_authentic_modules
          case action
          when :append
            modules << mod
          when :prepend
            modules = [mod] + modules
          end
          modules.uniq!
          write_inheritable_attribute(:acts_as_authentic_modules, modules)
        end
        
        # This is the same as add_acts_as_authentic_module, except that it removes the module from the list.
        def remove_acts_as_authentic_module(mod)
          acts_as_authentic_modules.delete(mod)
          acts_as_authentic_modules
        end
        
        private
          def acts_as_authentic_modules
            key = :acts_as_authentic_modules
            inheritable_attributes.include?(key) ? read_inheritable_attribute(key) : []
          end
          
          def rw_config(key, value, default_value = nil, read_value = nil)
            if value == read_value
              inheritable_attributes.include?(key) ? read_inheritable_attribute(key) : default_value
            else
              write_inheritable_attribute(key, value)
            end
          end
          
          def first_column_to_exist(*columns_to_check)
            columns_to_check.each { |column_name| return column_name.to_sym if column_names.include?(column_name.to_s) }
            columns_to_check.first && columns_to_check.first.to_sym
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