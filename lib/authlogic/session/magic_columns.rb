module Authlogic
  module Session
    # Just like ActiveRecord has "magic" columns, such as: created_at and updated_at. Authlogic has its own "magic" columns too:
    #
    #   Column name           Description
    #   login_count           Increased every time an explicit login is made. This will *NOT* increase if logging in by a session, cookie, or basic http auth
    #   failed_login_count    This increases for each consecutive failed login. See Authlogic::Session::BruteForceProtection and the consecutive_failed_logins_limit config option for more details.
    #   last_request_at       Updates every time the user logs in, either by explicitly logging in, or logging in by cookie, session, or http auth
    #   current_login_at      Updates with the current time when an explicit login is made.
    #   last_login_at         Updates with the value of current_login_at before it is reset.
    #   current_login_ip      Updates with the request remote_ip when an explicit login is made.
    #   last_login_ip         Updates with the value of current_login_ip before it is reset.
    module MagicColumns
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          after_persisting :set_last_request_at, :if => :set_last_request_at?
          validate :increase_failed_login_count
          before_save :update_info
          before_save :set_last_request_at, :if => :set_last_request_at?
        end
      end
      
      # Configuration for the magic columns feature.
      module Config
        # Every time a session is found the last_request_at field for that record is updatd with the current time, if that field exists. If you want to limit how frequent that field is updated specify the threshold
        # here. For example, if your user is making a request every 5 seconds, and you feel this is too frequent, and feel a minute is a good threashold. Set this to 1.minute. Once a minute has passed in between
        # requests the field will be updated.
        #
        # * <tt>Default:</tt> 0
        # * <tt>Accepts:</tt> integer representing time in seconds
        def last_request_at_threshold(value = nil)
          config(:last_request_at_threshold, value, 0)
        end
        alias_method :last_request_at_threshold=, :last_request_at_threshold
      end
      
      # The methods available for an Authlogic::Session::Base object that make up the magic columns feature.
      module InstanceMethods
        private
          def increase_failed_login_count
            if errors.on(password_field) && attempted_record.respond_to?(:failed_login_count)
              attempted_record.failed_login_count ||= 0
              attempted_record.failed_login_count += 1
            end
          end
        
          def update_info
            record.login_count = (record.login_count.blank? ? 1 : record.login_count + 1) if record.respond_to?(:login_count)
            record.failed_login_count = 0 if record.respond_to?(:failed_login_count)
          
            if record.respond_to?(:current_login_at)
              record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
              record.current_login_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
            end
          
            if record.respond_to?(:current_login_ip)
              record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
              record.current_login_ip = controller.request.remote_ip
            end
          end
          
          def set_last_request_at?
            record && record.class.column_names.include?("last_request_at") && (record.last_request_at.blank? || last_request_at_threshold.to_i.seconds.ago >= record.last_request_at)
          end
        
          def set_last_request_at
            record.last_request_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
          end
          
          def last_request_at_threshold
            self.class.last_request_at_threshold
          end
      end
    end
  end
end