module Authlogic
  module Session
    # = ActiveRecord Trickery
    #
    # Authlogic looks like ActiveRecord, sounds like ActiveRecord, but its not ActiveRecord. That's the goal here. This is useful for the various rails helper methods such as form_for, error_messages_for, or any
    # method that expects an ActiveRecord object. The point is to disguise the object as an ActiveRecord object so we have no problems.
    module ActiveRecordTrickery
      def self.included(klass) # :nodoc:
        klass.extend ClassMethods
        klass.send(:include, InstanceMethods)
      end
      
      module ClassMethods # :nodoc:
        def human_attribute_name(*args)
          klass.human_attribute_name(*args)
        end
        
        def human_name(*args)
          klass.human_name(*args)
        end
        
        def self_and_descendents_from_active_record
          [ self ]
        end
      end
      
      module InstanceMethods # :nodoc:
        def new_record?
          new_session?
        end
      end
    end
  end
end