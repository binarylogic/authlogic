module Authlogic
  module Session
    # = Perishability
    #
    # Maintains the perishable token, which is helpful for confirming records or authorizing records to reset their password. All that this
    # module does is reset it after a session have been saved, just keep it changing. The more it changes, the tighter the security.
    module Perishability
      def self.included(klass)
        klass.after_save :reset_perishable_token!
      end
      
      private
        def reset_perishable_token!
          record.send("reset_#{perishable_token_field}") if record.respond_to?("reset_#{perishable_token_field}") && !record.send("disable_#{perishable_token_field}_maintenance?")
        end
    end
  end
end