module Authgasm
  module ControllerAdapters
    # = Rails Adapter
    # Adapts authgasm to work with rails. The point is to close the gap between what authgasm expects and what the rails controller object
    # provides. Similar to how ActiveRecord has an adapter for MySQL, PostgreSQL, SQLite, etc.
    class RailsAdapter < AbstractAdapter
      def authenticate_with_http_basic(*args, &block)
        controller.authenticate_with_http_basic(*args, &block)
      end
      
      def cookies
        controller.send(:cookies)
      end
      
      def request
        controller.request
      end
      
      def session
        controller.session
      end
    end
    
    # = Rails Implementation
    # Lets Authgasm know about the controller object, AKA "activates" authgasm.
    module RailsImplementation
      def self.included(klass) # :nodoc:
        klass.prepend_before_filter :set_controller
      end

      private
        def set_controller
          Authgasm::Session::Base.controller = RailsAdapter.new(self)
        end
    end
  end
end

ActionController::Base.send(:include, Authgasm::ControllerAdapters::RailsImplementation)