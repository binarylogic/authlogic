# frozen_string_literal: true

require "authlogic/acts_as_authentic/queries/case_sensitivity"
require "authlogic/acts_as_authentic/queries/find_with_case"

module Authlogic
  module ActsAsAuthentic
    # Handles everything related to the login field.
    module Login
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end

      # Configuration for the login field.
      module Config
        # The name of the login field in the database.
        #
        # * <tt>Default:</tt> :login or :username, if they exist
        # * <tt>Accepts:</tt> Symbol
        def login_field(value = nil)
          rw_config(:login_field, value, first_column_to_exist(nil, :login, :username))
        end
        alias login_field= login_field

        # This method allows you to find a record with the given login. If you
        # notice, with Active Record you have the UniquenessValidator class.
        # They give you a :case_sensitive option. I handle this in the same
        # manner that they handle that. If you are using the login field, set
        # false for the :case_sensitive option in
        # validates_uniqueness_of_login_field_options and the column doesn't
        # have a case-insensitive collation, this method will modify the query
        # to look something like:
        #
        #   "LOWER(#{quoted_table_name}.#{login_field}) = LOWER(#{login})"
        #
        # If you don't specify this it just uses a regular case-sensitive search
        # (with the binary modifier if necessary):
        #
        #   "BINARY #{login_field} = #{login}"
        #
        # The above also applies for using email as your login, except that you
        # need to set the :case_sensitive in
        # validates_uniqueness_of_email_field_options to false.
        #
        # @api public
        def find_by_smart_case_login_field(login)
          field = login_field || email_field
          sensitive = Queries::CaseSensitivity.new(self, field).sensitive?
          find_with_case(field, login, sensitive)
        end

        private

        # @api private
        def find_with_case(field, value, sensitive)
          Queries::FindWithCase.new(self, field, value, sensitive).execute
        end
      end
    end
  end
end
