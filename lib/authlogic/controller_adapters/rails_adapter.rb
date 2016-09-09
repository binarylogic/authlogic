require 'action_controller'

module Authlogic
  module ControllerAdapters
    # Adapts authlogic to work with rails. The point is to close the gap between
    # what authlogic expects and what the rails controller object provides.
    # Similar to how ActiveRecord has an adapter for MySQL, PostgreSQL, SQLite,
    # etc.
    class RailsAdapter < AbstractAdapter
      class AuthlogicLoadedTooLateError < StandardError; end

      def authenticate_with_http_basic(&block)
        controller.authenticate_with_http_basic(&block)
      end

      def cookies
        controller.send(:cookies)
      end

      def cookie_domain
        @cookie_domain_key ||= Rails::VERSION::STRING >= '2.3' ? :domain : :session_domain
        controller.request.session_options[@cookie_domain_key]
      end

      def request_content_type
        request.format.to_s
      end

      # Lets Authlogic know about the controller object via a before filter, AKA
      # "activates" authlogic.
      module RailsImplementation
        def self.included(klass) # :nodoc:
          if defined?(::ApplicationController)
            raise AuthlogicLoadedTooLateError.new(
              <<-EOS.strip_heredoc
                Authlogic is trying to add a callback to ActionController::Base
                but ApplicationController has already been loaded, so the
                callback won't be copied into your application. Generally this
                is due to another gem or plugin requiring your
                ApplicationController prematurely, such as the
                resource_controller plugin. Please require Authlogic first,
                before these other gems / plugins.
              EOS
            )
          end

          # In Rails 4.0.2, the *_filter methods were renamed to *_action.
          if klass.respond_to? :prepend_before_action
            klass.prepend_before_action :activate_authlogic
          else
            klass.prepend_before_filter :activate_authlogic
          end
        end

        private

          def activate_authlogic
            Authlogic::Session::Base.controller = RailsAdapter.new(self)
          end
      end
    end
  end
end

ActionController::Base.send(:include, Authlogic::ControllerAdapters::RailsAdapter::RailsImplementation)
