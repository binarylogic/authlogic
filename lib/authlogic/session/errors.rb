module Authlogic
  module Session
    class Errors < ::ActiveRecord::Errors # :nodoc:
    end
    
    class NotActivated < ::StandardError # :nodoc:
      def initialize(session)
        super("You must activate the Authlogic::Session::Base.controller with a controller object before creating objects")
      end
    end
    
    class SessionInvalid < ::StandardError # :nodoc:
      def initialize(session)
        super("Authentication failed: #{session.errors.full_messages.to_sentence}")
      end
    end
  end
end