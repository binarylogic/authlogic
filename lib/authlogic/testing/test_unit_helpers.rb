module Authlogic
  module Testing # :nodoc:
    # = Test Unit Helpers
    #
    # Provides useful methods for testing in Test::Unit, lets you log records in, etc. Just include this in your test_helper filter:
    #
    #   require "authlogic/testing/test_unit_helpers"
    #
    # Then you will have the methods below to use in your tests.
    module TestUnitHelpers
      private
        def session_class(record) # :nodoc:
          record.class.acts_as_authentic_config[:session_class].constantize
        end
        
        # Sets the session for a record. This way when you execute a request in your test, session values will be present.
        def set_session_for(record)
          session_class = session_class(record)
          @request.session[session_class.session_key] = record.send(record.class.acts_as_authentic_config[:persistence_token_field])
          @request.session["#{session_class.session_key}_id"] = record.id
        end
        
        # Sets the cookie for a record. This way when you execute a request in your test, cookie values will be present.
        def set_cookie_for(record)
          session_class = session_class(record)
          @request.cookies[session_class.cookie_key] = record.send(record.class.acts_as_authentic_config[:persistence_token_field])
        end
        
        # Sets the HTTP_AUTHORIZATION header for basic HTTP auth. This way when you execute a request in your test that is trying to authenticate
        # with HTTP basic auth, the neccessary headers will be present.
        def set_http_auth_for(username, password)
          session_class = session_class(record)
          @request.env['HTTP_AUTHORIZATION'] = @controller.encode_credentials(username, password)
        end
    end
  end
end

Test::Unit::TestCase.send(:include, Authlogic::Testing::TestUnitHelpers)