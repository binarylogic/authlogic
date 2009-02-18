module Authlogic
  module ORMAdapters # :nodoc:
    module ActiveRecordAdapter # :nodoc:
      # = Acts As Authentic
      #
      # Provides the acts_as_authentic method to include in your models to help with authentication. You can include it as follows:
      #
      #   class User < ActiveRecord::Base
      #     acts_as_authentic :option => "value"
      #   end
      #
      # For a list of configuration options see the ActsAsAuthentic::Config module.
      module ActsAsAuthentic
        # All logic for this method is split up into sub modules. See sub modules for more details.
        def acts_as_authentic(options = {})
        end
      end
    end
  end
end

ActiveRecord::Base.extend Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic