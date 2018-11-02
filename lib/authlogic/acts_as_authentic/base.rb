# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    # Provides the base functionality for acts_as_authentic
    module Base
      def self.included(klass)
        klass.class_eval do
          class_attribute :acts_as_authentic_modules
          self.acts_as_authentic_modules ||= []
          extend Authlogic::Config
          extend Config
        end
      end

      # The primary configuration of a model (often, `User`) for use with
      # authlogic. These methods become class methods of ::ActiveRecord::Base.
      module Config
        # This includes a lot of helpful methods for authenticating records
        # which the Authlogic::Session module relies on. To use it just do:
        #
        #   class User < ApplicationRecord
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
        def acts_as_authentic
          return unless db_setup?
          yield self if block_given?
          acts_as_authentic_modules.each { |mod| include mod }
        end

        # Since this part of Authlogic deals with another class, ActiveRecord,
        # we can't just start including things in ActiveRecord itself. A lot of
        # these module includes need to be triggered by the acts_as_authentic
        # method call. For example, you don't want to start adding in email
        # validations and what not into a model that has nothing to do with
        # Authlogic.
        #
        # That being said, this is your tool for extending Authlogic and
        # "hooking" into the acts_as_authentic call.
        def add_acts_as_authentic_module(mod, action = :append)
          modules = acts_as_authentic_modules.clone
          case action
          when :append
            modules << mod
          when :prepend
            modules = [mod] + modules
          end
          modules.uniq!
          self.acts_as_authentic_modules = modules
        end

        # This is the same as add_acts_as_authentic_module, except that it
        # removes the module from the list.
        def remove_acts_as_authentic_module(mod)
          modules = acts_as_authentic_modules.clone
          modules.delete(mod)
          self.acts_as_authentic_modules = modules
        end

        private

        def db_setup?
          column_names
          true
        rescue StandardError
          false
        end

        def first_column_to_exist(*columns_to_check)
          if db_setup?
            columns_to_check.each do |column_name|
              if column_names.include?(column_name.to_s)
                return column_name.to_sym
              end
            end
          end
          columns_to_check.first&.to_sym
        end
      end
    end
  end
end

::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::Base
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::Email
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::LoggedInStatus
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::Login
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::MagicColumns
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::Password
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::PerishableToken
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::PersistenceToken
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::SessionMaintenance
::ActiveRecord::Base.send :include, Authlogic::ActsAsAuthentic::SingleAccessToken
