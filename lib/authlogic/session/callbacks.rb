module Authlogic
  module Session
    # = Callbacks
    #
    # Just like in ActiveRecord you have before_save, before_validation, etc. You have similar callbacks with Authlogic, see all callbacks below.
    module Callbacks
      CALLBACKS = %w(before_create after_create before_destroy after_destroy before_save after_save before_update after_update before_validation after_validation)

      def self.included(base) #:nodoc:
        [:destroy, :save, :valid?, :validate_credentials].each do |method|
          base.send :alias_method_chain, method, :callbacks
        end

        base.send :include, ActiveSupport::Callbacks
        base.define_callbacks *CALLBACKS
      end
      
      def destroy_with_callbacks # :nodoc:
        run_callbacks(:before_destroy)
        result = destroy_without_callbacks
        run_callbacks(:after_destroy) if result
        result
      end
      
      def save_with_callbacks # :nodoc:
        if new_session?
          run_callbacks(:before_create)
        else
          run_callbacks(:before_update)
        end
        run_callbacks(:before_save)
        result = save_without_callbacks
        if result
          if new_session?
            run_callbacks(:after_create)
          else
            run_callbacks(:after_update)
          end
          run_callbacks(:after_save)
        end
        result
      end
      
      def valid_with_callbacks?
        result = valid_without_callbacks?
        run_callbacks(:after_validation) if result
        result
      end
      
      def validate_credentials_with_callbacks # :nodoc:
        run_callbacks(:before_validation)
        validate_credentials_without_callbacks
      end
    end
  end
end