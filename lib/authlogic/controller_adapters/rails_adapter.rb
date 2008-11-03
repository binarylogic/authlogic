module Authlogic
  module ControllerAdapters
    # = Rails Adapter
    # Adapts authlogic to work with rails. The point is to close the gap between what authlogic expects and what the rails controller object
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
    # Lets Authlogic know about the controller object, AKA "activates" authlogic.
    module RailsImplementation
      def self.included(klass) # :nodoc:
        klass.prepend_before_filter :set_controller
      end

      private
        def set_controller
          Authlogic::Session::Base.controller = RailsAdapter.new(self)
        end
    end
  end
end

ActionController::Base.send(:include, Authlogic::ControllerAdapters::RailsImplementation)