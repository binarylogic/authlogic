module Authlogic
  module Session
    module Session
      def self.included(klass)
        klass.after_save :update_session!
        klass.after_destroy :update_session!
        klass.after_find :update_session!
      end
      
      # Tries to validate the session from information in the session
      def valid_session?
        if session_credentials
          self.unauthorized_record = search_for_record("find_by_#{remember_token_field}", session_credentials)
          return valid?
        end
        
        false
      end
      
      private
        def session_credentials
          controller.session[session_key]
        end
        
        def update_session!
          controller.session[session_key] = record && record.send(remember_token_field)
        end
    end
  end
end