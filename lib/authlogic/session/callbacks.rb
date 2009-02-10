module Authlogic
  module Session
    # = Callbacks
    #
    # Just like in ActiveRecord you have before_save, before_validation, etc. You have similar callbacks with Authlogic, see the METHODS constant below. The order of execution is as follows:
    #
    # Here is the order they execute
    #
    #   before_find
    #   after_find
    #   
    #   before_validation
    #   before_validation_on_create
    #   before_validation_on_update
    #   validate
    #   after_validation_on_update
    #   after_validation_on_create
    #   after_validation
    #   
    #   before_save
    #   before_create
    #   before_update
    #   after_update
    #   after_create
    #   after_save
    #   
    #   before_destroy
    #   destroy
    #   after_destroy
    #
    # **WARNING**: unlike ActiveRecord, these callbacks must be set up on the class level:
    #
    #   class UserSession < Authlogic::Session::Base
    #     before_validation :my_method
    #     validate :another_method
    #     # ..etc
    #   end
    #
    # Defining a "before_validation" method will work, but overwrite the execution of the callback chain, so you must chose one method or the other. The preferred method is the method above.
    module Callbacks
      METHODS = [
        "before_find", "after_find",
        "before_validation", "before_validation_on_create", "before_validation_on_update", "validate", "after_validation_on_update", "after_validation_on_create", "after_validation",
        "before_save", "before_create", "before_update", "after_update", "after_create", "after_save",
        "before_destroy", "after_destroy"
      ]
      
      def self.included(base) #:nodoc:
        base.send :include, ActiveSupport::Callbacks
        base.define_callbacks *METHODS
      end
      
      METHODS.each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}
            run_callbacks(:#{method})
          end
        end_eval
      end
    end
  end
end