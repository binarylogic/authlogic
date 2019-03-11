# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    # Maintains the persistence token, the token responsible for persisting sessions. This token
    # gets stored in the session and the cookie.
    module PersistenceToken
      def self.included(klass)
        klass.class_eval do
          add_acts_as_authentic_module(Methods)
        end
      end

      # Methods for the persistence token.
      module Methods
        def self.included(klass)
          klass.class_eval do
            extend ClassMethods
            include InstanceMethods

            # If the table does not have a password column, then
            # `after_password_set` etc. will not be defined. See
            # `Authlogic::ActsAsAuthentic::Password::Callbacks.included`
            if respond_to?(:after_password_set) && respond_to?(:after_password_verification)
              after_password_set :reset_persistence_token
              after_password_verification :reset_persistence_token!, if: :reset_persistence_token?
            end

            validates_presence_of :persistence_token
            validates_uniqueness_of :persistence_token, case_sensitive: true,
                                                        if: :will_save_change_to_persistence_token?

            before_validation :reset_persistence_token, if: :reset_persistence_token?
          end
        end

        # :nodoc:
        module ClassMethods
          # Resets ALL persistence tokens in the database, which will require
          # all users to re-authenticate.
          def forget_all
            # Paginate these to save on memory
            find_each(batch_size: 50, &:forget!)
          end
        end

        # :nodoc:
        module InstanceMethods
          # Resets the persistence_token field to a random hex value.
          def reset_persistence_token
            self.persistence_token = Authlogic::Random.hex_token
          end

          # Same as reset_persistence_token, but then saves the record.
          def reset_persistence_token!
            reset_persistence_token
            save_without_session_maintenance(validate: false)
          end
          alias forget! reset_persistence_token!

          private

          def reset_persistence_token?
            persistence_token.blank?
          end
        end
      end
    end
  end
end
