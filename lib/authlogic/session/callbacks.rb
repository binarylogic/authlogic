module Authlogic
  module Session
    # = Callbacks
    #
    # Just like in ActiveRecord you have before_save, before_validation, etc. You have similar callbacks with Authlogic, see all callbacks below.
    module Callbacks
      CALLBACKS = %w(before_create after_create before_destroy after_destroy before_find after_find before_save after_save before_update after_update before_validation after_validation)

      def self.included(base) #:nodoc:
        [:destroy, :find_record, :save, :validate].each do |method|
          base.send :alias_method_chain, method, :callbacks
        end

        base.send :include, ActiveSupport::Callbacks
        base.define_callbacks *CALLBACKS
      end
      
      # Runs the following callbacks:
      #
      #   before_destroy
      #   destroy
      #   after_destroy # only if destroy is successful
      def destroy_with_callbacks
        run_callbacks(:before_destroy)
        result = destroy_without_callbacks
        run_callbacks(:after_destroy) if result
        result
      end
      
      # Runs the following callbacks:
      #
      #   before_find
      #   find_record
      #   after_find # if a record was found
      def find_record_with_callbacks
        run_callbacks(:before_find)
        result = find_record_without_callbacks
        run_callbacks(:after_find) if result
        result
      end
      
      # Runs the following callbacks:
      #
      #   before_save
      #   before_create # only if new_session? == true
      #   before_update # only if new_session? == false
      #   save
      #   # the following are only run is save is successful
      #   after_save
      #   before_update # only if new_session? == false
      #   before_create # only if new_session? == true
      def save_with_callbacks(&block)
        run_callbacks(:before_save)
        if new_session?
          run_callbacks(:before_create)
        else
          run_callbacks(:before_update)
        end
        result = save_without_callbacks(&block)
        if result
          run_callbacks(:after_save)
          
          if new_session?
            run_callbacks(:after_create)
          else
            run_callbacks(:after_update)
          end
        end
        result
      end
      
      # Runs the following callbacks:
      #
      #   before_validation
      #   validate
      #   after_validation # only if errors.empty?
      def validate_with_callbacks
        run_callbacks(:before_validation)
        validate_without_callbacks
        run_callbacks(:after_validation) if errors.empty?
      end
    end
  end
end