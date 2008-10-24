module Authgasm
  # = Controller
  # Adds a before_filter to set the controller object so that Authgasm can do its session and cookie magic
  module Controller
    def self.included(klass) # :nodoc:
      klass.prepend_before_filter :set_controller
    end
    
    private
      def set_controller
        Authgasm::Session::Base.controller = self
      end
  end
end

ActionController::Base.send(:include, Authgasm::Controller)