module Authlogic
  module Session
    # Authlogic looks like ActiveRecord, sounds like ActiveRecord, but its not
    # ActiveRecord. That's the goal here. This is useful for the various rails
    # helper methods such as form_for, error_messages_for, or any method that
    # expects an ActiveRecord object. The point is to disguise the object as an
    # ActiveRecord object so we can take advantage of the many ActiveRecord
    # tools.
    module ActiveRecordTrickery
      def self.included(klass)
        klass.extend ActiveModel::Naming
        klass.extend ActiveModel::Translation

        # Support ActiveModel::Name#name for Rails versions before 4.0.
        unless klass.model_name.respond_to?(:name)
          ActiveModel::Name.module_eval do
            alias_method :name, :to_s
          end
        end

        klass.extend ClassMethods
        klass.send(:include, InstanceMethods)
      end

      module ClassMethods
        # How to name the class, works JUST LIKE ActiveRecord, except it uses
        # the following namespace:
        #
        #   authlogic.models.user_session
        def human_name(*)
          I18n.t("models.#{name.underscore}", count: 1, default: name.humanize)
        end

        def i18n_scope
          I18n.scope
        end
      end

      module InstanceMethods
        # Don't use this yourself, this is to just trick some of the helpers
        # since this is the method it calls.
        def new_record?
          new_session?
        end

        def persisted?
          !(new_record? || destroyed?)
        end

        def destroyed?
          record.nil?
        end

        def to_key
          new_record? ? nil : record.to_key
        end

        # For rails >= 3.0
        def to_model
          self
        end
      end
    end
  end
end
