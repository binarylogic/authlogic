module Authlogic
  module Session
    # = Brute Force Protection
    #
    # A brute force attacks is executed by hammering a login with as many password combinations as possible, until one works. A brute force attacked is
    # generally combated with a slow hasing algorithm such as BCrypt. You can increase the cost, which makes the hash generation slower, and ultimately
    # increases the time it takes to execute a brute force attack. Just to put this into perspective, if a hacker was to gain access to your server
    # and execute a brute force attack locally, meaning there is no network lag, it would take decades to complete. Now throw in network lag for hackers
    # executing this attack over a network, and it would take centuries.
    #
    # But for those that are extra paranoid and can't get enough protection, why not stop them as soon as you realize something isn't right? That's
    # what this module is all about. By default the consecutive_failed_logins_limit configuration option is set to 50, if someone consecutively fails to login
    # after 50 attempts their account will be suspended. This is a very liberal number and at this point it should be obvious that something is not right.
    # If you wish to lower this number just set the configuration to a lower number:
    #
    #   class UserSession < Authlogic::Session::Base
    #     consecutive_failed_logins_limit 10
    #   end
    module BruteForceProtection
      def self.included(klass)
        klass.validate :validate_failed_logins, :if => :protect_from_brute_force_attacks?
        klass.validate :increase_failed_login_count, :if => :protect_from_brute_force_attacks?
        klass.after_save :reset_failed_login_count, :if => :protect_from_brute_force_attacks?
      end
      
      # This allows you to reset the failed_login_count for the associated record, allowing that account to start at 0 and continue
      # trying to login. So, if an account exceeds the limit the only way they will be able to log back in is if your execute this
      # method, which merely resets the failed_login_count field to 0.
      def reset_failed_login_count
        record.failed_login_count = 0
      end
      
      private
        def protect_from_brute_force_attacks?
          r = attempted_record || record
          r && r.respond_to?(:failed_login_count) && consecutive_failed_logins_limit > 0
        end
        
        def validate_failed_logins
          if attempted_record.failed_login_count && attempted_record.failed_login_count >= consecutive_failed_logins_limit
            errors.clear # Clear all other error messages, as they are irrelevant at this point and can only provide additional information that is not needed
            errors.add_to_base(I18n.t('error_messages.consecutive_failed_logins_limit_exceeded', :default => "Consecutive failed logins limit exceeded, account is disabled."))
          end
        end

        def increase_failed_login_count
          if errors.on(password_field)
            attempted_record.failed_login_count ||= 0
            attempted_record.failed_login_count += 1
          end
        end
    end
  end
end