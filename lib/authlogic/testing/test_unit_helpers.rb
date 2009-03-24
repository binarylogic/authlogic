module Authlogic
  # Various utilities to help with testing. Keep in mind, Authlogic is thoroughly tested for you, the only thing you should be
  # testing is code you write, such as code in your controller.
  module Testing
    # Provides useful methods for testing in Test::Unit, lets you log records in, etc. Just include this in your test_helper filter:
    #
    #   require "authlogic/testing/test_unit_helpers"
    #
    # Then you will have the methods below to use in your tests.
    module TestUnitHelpers
      private
        def session_class(record)
          record.class.session_class
        end
        
        # Sets the session for a record. This way when you execute a request in your test, session values will be present.
        def set_session_for(record)
          session_class = session_class(record)
          @request.session[session_class.session_key] = record.persistence_token
          @request.session["#{session_class.session_key}_#{record.class.primary_key}"] = record.id
        end
        
        # Sets the cookie for a record. This way when you execute a request in your test, cookie values will be present.
        def set_cookie_for(record)
          session_class = session_class(record)
          @request.cookies[session_class.cookie_key] = record.persistence_token
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