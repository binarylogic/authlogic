module Authlogic
  module ActsAsAuthentic
    # This module is responsible for maintaining the single_access token. For more information the single access token and how to use it,
    # see the Authlogic::Session::Params module.
    module SingleAccessToken
      module Config
        def change_single_access_token_with_password(value = nil)
          config(:change_single_access_token_with_password, value, false)
        end
        alias_method :change_single_access_token_with_password=, :change_single_access_token_with_password
      end
      
      module Methods
        def self.included(klass)
          klass.class_eval do
            validates_uniqueness_of :single_access_token, :if => :single_access_token_changed?
            before_validation :reset_single_access_token, :if => :reset_single_access_token?
            after_password_set :reset_single_access_token, :if => :change_single_access_token_with_password?
          end
        end
        
        # Resets the single_access_token to a random friendly token.
        def reset_single_access_token
          self.single_access_token = Authlogic::Random.friendly_token
        end
        
        # same as reset_single_access_token, but then saves the record.
        def reset_single_access_token!
          reset_single_access_token
          save_without_session_maintenance
        end
      
        protected
          def reset_single_access_token?
            single_access_token.blank?
          end
          
          def change_single_access_token_with_password?
            aaa_config.change_single_access_token_with_password
          end
      end
    end
  end
end