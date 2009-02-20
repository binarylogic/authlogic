module Authlogic
  module Session
    module RecordInfo
      def self.included(klass)
        klass.before_create :update_info
      end
      
      private
        def update_info
          record.login_count = (record.login_count.blank? ? 1 : record.login_count + 1) if record.respond_to?(:login_count)
          
          if record.respond_to?(:current_login_at)
            record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
            record.current_login_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
          end
          
          if record.respond_to?(:current_login_ip)
            record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
            record.current_login_ip = controller.request.remote_ip
          end
        end
    end
  end
end