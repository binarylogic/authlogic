module Authlogic
  module Session
    # = Timeout
    #
    # This is reponsibile for determining if the session is stale or fresh. It is also responsible for maintaining the last_request_at value if the column is present.
    #
    # Think about how financial websites work. If you are inactive after a certain period of time you must log back in. By default this is disabled, but if enabled this
    # module kicks in. See the logout_on_timeout configuration option for how to turn this on.
    module Timeout
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :find_record, :timeout
          before_find :reset_stale_state
          after_find :set_last_request_at
          before_save :set_last_request_at
        end
      end
      
      # This implements the stale functionality when trying to find a session. If the session is stale the record will be cleared, but the session object will still be
      # returned. This allows you to perform a current_user_session.stale? query in order to inform your users of why they need to log back in.
      def find_record_with_timeout
        result = find_record_without_timeout
        if result && stale?
          self.record = nil
          @stale = true
        end
        result
      end
    
      # Tells you if the record is stale or not. Meaning the record has timed out. This will only return true if you set logout_on_timeout to true in your configuration.
      # Basically how a bank website works. If you aren't active over a certain period of time your session becomes stale and requires you to log back in.
      def stale?
        @stale == true || (logout_on_timeout? && record && record.logged_out?)
      end
    
      private
        def reset_stale_state
          @stale = nil
        end

        def set_last_request_at
          if record && record.class.column_names.include?("last_request_at") && (record.last_request_at.blank? || last_request_at_threshold.to_i.seconds.ago >= record.last_request_at)
            record.last_request_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
          end
        end
    end
  end
end