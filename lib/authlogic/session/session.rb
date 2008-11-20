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
        persistence_token, record_id = session_credentials
        if !persistence_token.blank?
          if record_id
            record = search_for_record("find_by_id", record_id)
            self.unauthorized_record = record if record && record.send(persistence_token_field) == persistence_token
          else
            # For backwards compatibility, will eventually be removed, just need to let the sessions update theirself
            record = search_for_record("find_by_#{persistence_token_field}", persistence_token)
            if record
              controller.session["#{session_key}_id"] = record.send(record.class.primary_key)
              self.unauthorized_record = record
            end
          end
          return valid?
        end
        
        false
      end
      
      private
        def session_credentials
          [controller.session[session_key], controller.session["#{session_key}_id"]].compact
        end
        
        def update_session!
          controller.session[session_key] = record && record.send(persistence_token_field)
          controller.session["#{session_key}_id"] = record && record.send(record.class.primary_key)
        end
    end
  end
end