# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    # Sometimes models won't have an explicit "login" or "username" field.
    # Instead they want to use the email field. In this case, authlogic provides
    # validations to make sure the email submited is actually a valid email.
    # Don't worry, if you do have a login or username field, Authlogic will
    # still validate your email field. One less thing you have to worry about.
    module Email
      def self.included(klass)
        klass.class_eval do
          extend Config
        end
      end

      # Configuration to modify how Authlogic handles the email field.
      module Config
        # The name of the field that stores email addresses.
        #
        # * <tt>Default:</tt> :email, if it exists
        # * <tt>Accepts:</tt> Symbol
        def email_field(value = nil)
          rw_config(:email_field, value, first_column_to_exist(nil, :email, :email_address))
        end
        alias email_field= email_field
      end
    end
  end
end
