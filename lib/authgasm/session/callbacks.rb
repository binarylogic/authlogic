module Authgasm
  module Session
    # = Callbacks
    #
    # Just like in ActiveRecord you have before_save, before_validation, etc. You have similar callbacks with Authgasm, see all callbacks below.
    module Callbacks
      CALLBACKS = %w(before_create after_create before_destroy after_destroy before_update after_update before_validation after_validation)

      def self.included(base) #:nodoc:
        [:create, :destroy, :update, :valid?].each do |method|
          base.send :alias_method_chain, method, :callbacks
        end

        base.send :include, ActiveSupport::Callbacks
        base.define_callbacks *CALLBACKS
      end
            
      def create_with_callbacks(updating = false) # :nodoc:
        run_callbacks(:before_create)
        result = create_without_callbacks(updating)
        run_callbacks(:after_create)
        result
      end
      
      def destroy_with_callbacks # :nodoc:
        run_callbacks(:before_destroy)
        result = destroy_without_callbacks
        run_callbacks(:after_destroy)
        result
      end
      
      def update_with_callbacks # :nodoc:
        run_callbacks(:before_update)
        result = update_without_callbacks
        run_callbacks(:after_update)
        result
      end
      
      def valid_with_callbacks?(set_session = false) # :nodoc:
        run_callbacks(:before_validation)
        result = valid_without_callbacks?(set_session)
        run_callbacks(:after_validation)
        result
      end
    end
  end
end