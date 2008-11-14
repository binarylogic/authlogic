module Authlogic
  module Session
    # = Session
    #
    # Handles all parts of authentication that deal with sessions. Such as persisting a session and saving / destroy a session.
    module Session
      def self.included(klass)
        klass.after_save :update_session!, :if => :persisting?
        klass.after_destroy :update_session!, :if => :persisting?
        klass.after_find :update_session!, :if => :persisting?
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