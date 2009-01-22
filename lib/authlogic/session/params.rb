module Authlogic
  module Session
    # = Params
    #
    # Tries to log the user in via params. Think about cookies and sessions. They are just hashes in your controller, so are params. People never
    # look at params as an authentication option, but it can be useful for logging into private feeds, etc. Logging in a user is as simple as:
    #
    #   https://www.domain.com?user_credentials=[insert single access token here]
    #
    # Wait, what is a single access token? It is all explained in the README. Checkout the "Tokens" section in the README, there is section about
    # single access tokens. For security reasons, this type of authentication is ONLY available via single access tokens, you can NOT pass your persistence token.
    # Which means you must have a single_access_token field in your database.
    module Params
      # Tries to validate the session from information in the params token
      def valid_params?
        if params_credentials && single_access_token_field && (single_access_allowed_request_types.include?(controller.request_content_type) || single_access_allowed_request_types.include?(:all) || controller.single_access_allowed?)
          self.unauthorized_record = search_for_record("find_by_#{single_access_token_field}", params_credentials)
          self.persisting = false
          return true if valid?
          self.persisting = true
        else
          false
        end
      end
      
      private
        def params_credentials
          controller.params[params_key]
        end
    end
  end
end