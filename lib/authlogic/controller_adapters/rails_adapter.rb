# frozen_string_literal: true

module Authlogic
  module ControllerAdapters
    # Adapts authlogic to work with rails. The point is to close the gap between
    # what authlogic expects and what the rails controller object provides.
    # Similar to how ActiveRecord has an adapter for MySQL, PostgreSQL, SQLite,
    # etc.
    class RailsAdapter < AbstractAdapter
      def authenticate_with_http_basic(&block)
        controller.authenticate_with_http_basic(&block)
      end

      # Returns a `ActionDispatch::Cookies::CookieJar`. See the AC guide
      # http://guides.rubyonrails.org/action_controller_overview.html#cookies
      def cookies
        controller.send(:cookies)
      end

      def cookie_domain
        controller.request.session_options[:domain]
      end

      def request_content_type
        request.format.to_s
      end

      # Lets Authlogic know about the controller object via a before filter, AKA
      # "activates" authlogic.
      module RailsImplementation
        def self.included(klass) # :nodoc:
          klass.prepend_before_action :activate_authlogic
        end

        private

        def activate_authlogic
          Authlogic::Session::Base.controller = RailsAdapter.new(self)
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include Authlogic::ControllerAdapters::RailsAdapter::RailsImplementation
end
