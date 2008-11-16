module Authlogic
  module Session
    # = Password Reset
    #
    # Provides utilities that assist in maintaining the password reset token. This module just resets the token after a session has been saved, just to keep changing it and add extra security.
    module PasswordReset
      def self.included(klass)
        klass.after_save :reset_password_reset_token!
      end
      
      private
        def reset_password_reset_token!
          record.send("reset_#{password_reset_token_field}!") if record.respond_to?("reset_#{password_reset_token_field}!")
        end
    end
  end
end