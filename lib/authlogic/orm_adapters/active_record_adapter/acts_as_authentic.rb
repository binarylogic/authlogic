module Authlogic
  module ORMAdapters # :nodoc:
    module ActiveRecordAdapter # :nodoc:
      # = Acts As Authentic
      # Provides the acts_as_authentic method to include in your models to help with authentication. See sub modules for more information.
      module ActsAsAuthentic
        # All logic for this method is split up into sub modules. This a stub to create a method chain off of and provide documentation. See sub modules for more details.
        def acts_as_authentic(options = {})
        end
      end
    end
  end
end

ActiveRecord::Base.extend Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic