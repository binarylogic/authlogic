module Authlogic
  module Session
    # Handles all authentication that deals with basic HTTP auth.
    module HttpAuth
      def self.included(klass)
        klass.persist :persist_by_http_auth
      end
      
      private
        def persist_by_http_auth
          controller.authenticate_with_http_basic do |login, password|
            if !login.blank? && !password.blank?
              send("#{login_field}=", login)
              send("#{password_field}=", password)
              return valid?
            end
          end
        
          false
        end
    end
  end
end