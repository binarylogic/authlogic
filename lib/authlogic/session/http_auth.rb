module Authlogic
  module Session
    # Handles all authentication that deals with basic HTTP auth. Which is authentication built into the HTTP protocol:
    #
    #   http://username:password@whatever.com
    #
    # Also, if you are not comfortable letting users pass their raw username and password you can always use the single
    # access token. See Authlogic::Session::Params for more info.
    module HttpAuth
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          persist :persist_by_http_auth, :if => :persist_by_http_auth?
        end
      end
      
      # Configuration for the HTTP basic auth feature of Authlogic.
      module Config
        # Do you want to allow your users to log in via HTTP basic auth?
        #
        # I recommend keeping this enabled. The only time I feel this should be disabled is if you are not comfortable
        # having your users provide their raw username and password. Whatever the reason, you can disable it here.
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def allow_http_basic_auth(value = nil)
          rw_config(:allow_http_basic_auth, value, true)
        end
        alias_method :allow_http_basic_auth=, :allow_http_basic_auth
      end
      
      # Instance methods for the HTTP basic auth feature of authlogic.
      module InstanceMethods
        private
          def persist_by_http_auth?
            allow_http_basic_auth? && login_field && password_field
          end
        
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
        
          def allow_http_basic_auth?
            self.class.allow_http_basic_auth == true
          end
      end
    end
  end
end