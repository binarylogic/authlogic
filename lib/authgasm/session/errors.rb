module Authgasm
  module Session
    class Errors < ::ActiveRecord::Errors # :nodoc:
    end
    
    class SessionInvalid < ::StandardError # :nodoc:
      def initialize(session)
        super("Authentication failed: #{session.errors.full_messages.to_sentence}")
      end
    end
  end
end