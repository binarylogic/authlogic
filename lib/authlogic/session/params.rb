module Authlogic
  module Session
    # = Params
    #
    # Tries to log the user in via params. Think about cookies and sessions. They are just hashes in your controller, so are params. People never
    # look at params as an authentication option, but it can be useful for logging into private feeds. Logging in a user is as simple as:
    #
    #   http://www.domain.com?user_credentials=[insert remember token here]
    #
    # The user_credentials is based on the name of your session, the above example assumes UserSession. Also, this can be modified via configuration.
    module Params
      # Tries to validate the session from information in the params token
      def valid_params?
        if params_credentials
          self.unauthorized_record = search_for_record("find_by_#{remember_token_field}", params_credentials)
          return valid?
        end
        
        false
      end
      
      private
        def params_credentials
          controller.params[params_key]
        end
    end
  end
end