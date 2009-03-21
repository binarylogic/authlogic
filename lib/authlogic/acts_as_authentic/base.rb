module Authlogic
  module ActsAsAuthentic
    # Adds in the acts_as_authentic method to ActiveRecord.
    module Base
      # This includes a lot of helpful methods for authenticating records which The Authlogic::Session module relies on.
      # To use it just do:
      #
      #   class User < ActiveRecord::Base
      #     acts_as_authentic
      #   end
      #
      # Configuration is easy:
      #
      #   acts_as_authentic do |c|
      #     c.my_configuration_option = my_value
      #   end
      #
      # See the various sub modules for the configuration they provide.
      def acts_as_authentic(&block)
        cattr_accessor :aaa_config
        c = Config.new(self)
        yield c if block_given?
        self.aaa_config = c
        
        # We need to include these after configuration is set, because some of these module
        # use the configuration when included.
        include Email::Methods
        include LoggedInStatus::Methods
        include Login::Methods
        include MagicColumns::Methods
        include Password::Callbacks
        include Password::Methods
        include PerishableToken::Methods if column_names.include?("perishable_token")
        include PersistenceToken::Methods
        include SessionMaintenance::Methods
        include SingleAccessToken::Methods if column_names.include?("single_access_token")
      end
    end
    
    ::ActiveRecord::Base.extend(Base) if defined?(::ActiveRecord)
  end
end