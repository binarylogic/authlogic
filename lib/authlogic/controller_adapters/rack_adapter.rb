module Authlogic
  module ControllerAdapters
    # Adapter for authlogic to make it function as a Rack middleware.
    # First you'll have write your own Rack adapter where you have to set your cookie domain.
    #
    #     class YourRackAdapter < Authlogic::ControllerAdapters::RackAdapter
    #       def cookie_domain
    #         'your_cookie_domain_here.com'
    #       end
    #     end
    #
    # Next you need to set up a rack middleware like this:
    #
    #     class AuthlogicMiddleware
    #       def initialize(app)
    #         @app = app
    #       end
    #
    #       def call(env)
    #         YourRackAdapter.new(env)
    #         @app.call(env)
    #       end
    #     end
    #
    # And that is all! Now just load this middleware into rack:
    #
    #     use AuthlogicMiddleware
    #
    # Authlogic will expect a User and a UserSession object to be present:
    #
    #     class UserSession < Authlogic::Session::Base
    #       # Authlogic options go here
    #     end
    #
    #     class User < ActiveRecord::Base
    #       acts_as_authentic
    #     end
    #
    class RackAdapter < AbstractAdapter
      def initialize(env)
        # We use the Rack::Request object as the controller object.
        # For this to work, we have to add some glue.
        request = Rack::Request.new(env)

        request.instance_eval do
          def request
            self
          end

          def remote_ip
            self.ip
          end
        end

        super(request)
        Authlogic::Session::Base.controller = self
      end

      # Rack Requests stores cookies with not just the value, but also with
      # flags and expire information in the hash. Authlogic does not like this,
      # so we drop everything except the cookie value.
      def cookies
        controller
          .cookies
          .map { |key, value_hash| { key => value_hash[:value] } }
          .inject(:merge) || {}
      end
    end
  end
end
