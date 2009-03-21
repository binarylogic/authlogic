module Authlogic
  module Session
    # The errors in Authlogic work JUST LIKE ActiveRecord. In fact, it uses the exact same ActiveRecord errors class. Use it the same way:
    #
    #   class UserSession
    #     validate :check_if_awesome
    #
    #     private
    #       def check_if_awesome
    #         errors.add(:login, "must contain awesome") if login && !login.include?("awesome")
    #         errors.add_to_base("You must be awesome to log in") unless record.awesome?
    #       end
    #   end
    class Errors < ::ActiveRecord::Errors
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