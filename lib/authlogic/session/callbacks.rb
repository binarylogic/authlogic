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
    #   save record if changed?
    #   
    #   before_validation
    #   before_validation_on_create
    #   before_validation_on_update
    #   validate
    #   after_validation_on_update
    #   after_validation_on_create
    #   after_validation
    #   save record if changed?
    #   
    #   before_save
    #   before_create
    #   before_update
    #   after_update
    #   after_create
    #   after_save
    #   save record if changed?
    #   
    #   before_destroy
    #   destroy
    #   after_destroy
    #
    # Notice the "save record if changed?" lines above. This helps with performance. If you need to make changes to the associated record, there is no need to save the record, Authlogic will do it for you.
    # This allow multiple modules to modify the record and execute as few queries as possible.
    #
    # **WARNING**: unlike ActiveRecord, these callbacks must be set up on the class level:
    #
    #   class UserSession < Authlogic::Session::Base
    #     before_validation :my_method
    #     validate :another_method
    #     # ..etc
    #   end
    #
    # You can NOT define a "before_validation" method, this is bad practice and does not allow Authlogic to extend properly with multiple extensions. Please ONLY use the method above.
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