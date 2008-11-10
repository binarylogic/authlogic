module Authlogic
  module Session
    module Cookies
      def self.included(klass)
        klass.after_save :save_cookie
        klass.after_destroy :destroy_cookie
      end
      
      # Tries to validate the session from information in the cookie
      def valid_cookie?
        if cookie_credentials
          self.unauthorized_record = search_for_record("find_by_#{remember_token_field}", cookie_credentials)
          return valid?
        end
        
        false
      end
      
      private
        def cookie_credentials
          controller.cookies[cookie_key]
        end
        
        def save_cookie
          controller.cookies[cookie_key] = {
            :value => record.send(remember_token_field),
            :expires => remember_me_until
          }
        end
        
        def destroy_cookie
          controller.cookies.delete cookie_key
        end
    end
  end
end