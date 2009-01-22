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
        klass.after_find :update_last_request_at!
        klass.after_save :update_last_request_at!
      end
      
      def stale?
        logout_on_timeout? && record && record.logged_out?
      end
      
      private
        def update_last_request_at!
          if record.class.column_names.include?("last_request_at") && (record.last_request_at.blank? || last_request_at_threshold.to_i.seconds.ago >= record.last_request_at)
            record.last_request_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
            record.save_without_session_maintenance(false)
          end
        end
    end
  end
end