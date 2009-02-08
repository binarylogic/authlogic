module Authlogic
  module Session
    # = Cookies
    #
    # Handles all authentication that deals with cookies, such as persisting a session and saving / destroying a session.
    module Cookies
      def self.included(klass)
        klass.after_save :save_cookie, :if => :persisting?
        klass.after_destroy :destroy_cookie, :if => :persisting?
      end
      
      # Tries to validate the session from information in the cookie
      def valid_cookie?
        if cookie_credentials
          self.unauthorized_record = search_for_record("find_by_#{persistence_token_field}", cookie_credentials)
          valid?
        else
          false
        end
      end
      
      private
        def cookie_credentials
          controller.cookies[cookie_key]
        end
        
        def save_cookie
          controller.cookies[cookie_key] = {
            :value => record.send(persistence_token_field),
            :expires => remember_me_until,
            :domain => controller.cookie_domain
          }
        end
        
        def destroy_cookie
          controller.cookies.delete cookie_key, :domain => controller.cookie_domain
        end
    end
  end
end