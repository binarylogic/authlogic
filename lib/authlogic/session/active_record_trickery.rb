module Authlogic
  module Session
    # Authlogic looks like ActiveRecord, sounds like ActiveRecord, but its not ActiveRecord. That's the goal here.
    # This is useful for the various rails helper methods such as form_for, error_messages_for, or any method that
    # expects an ActiveRecord object. The point is to disguise the object as an ActiveRecord object so we can take
    # advantage of the many ActiveRecord tools.
    module ActiveRecordTrickery
      def self.included(klass)
        klass.extend ClassMethods
        klass.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def human_attribute_name(attribute_key_name, options = {})
          options[:count] ||= 1
          options[:default] ||= attribute_key_name.humanize
          I18n.t("attributes.#{name.underscore}.#{attribute_key_name}", options)
        end
        
        def human_name(*args)
          I18n.t("models.#{name.underscore}", {:count => 1, :default => name.humanize})
        end
        
        # For rails < 2.3, mispelled
        def self_and_descendents_from_active_record
          [self]
        end
        
        # For Rails >2.3, fix mispelling
        def self_and_descendants_from_active_record
          [self]
        end
      end
      
      module InstanceMethods
        def new_record?
          new_session?
        end
      end
    end
  end
end