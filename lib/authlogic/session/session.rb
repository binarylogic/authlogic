# frozen_string_literal: true

module Authlogic
  module Session
    # Handles all parts of authentication that deal with sessions. Such as persisting a
    # session and saving / destroy a session.
    module Session
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          persist :persist_by_session
          after_save :update_session
          after_destroy :update_session
          after_persisting :update_session, unless: :single_access?
        end
      end

      # Configuration for the session feature.
      module Config
        # Works exactly like cookie_key, but for sessions. See cookie_key for more info.
        #
        # * <tt>Default:</tt> cookie_key
        # * <tt>Accepts:</tt> Symbol or String
        def session_key(value = nil)
          rw_config(:session_key, value, cookie_key)
        end
        alias session_key= session_key
      end

      # :nodoc:
      module InstanceMethods
        private

        # Tries to validate the session from information in the session
        def persist_by_session
          persistence_token, record_id = session_credentials
          if !persistence_token.nil?
            record = persist_by_session_search(persistence_token, record_id)
            if record && record.persistence_token == persistence_token
              self.unauthorized_record = record
            end
            valid?
          else
            false
          end
        end

        # Allow finding by persistence token, because when records are created
        # the session is maintained in a before_save, when there is no id.
        # This is done for performance reasons and to save on queries.
        def persist_by_session_search(persistence_token, record_id)
          if record_id.nil?
            search_for_record("find_by_persistence_token", persistence_token.to_s)
          else
            search_for_record("find_by_#{klass.primary_key}", record_id.to_s)
          end
        end

        # @api private
        # @return [String] - Examples:
        # - user_credentials_id
        # - ziggity_zack_user_credentials_id
        #   - ziggity_zack is an "id", see `Authlogic::Session::Id`
        #   - see persistence_token_test.rb
        def session_compound_key
          "#{session_key}_#{klass.primary_key}"
        end

        def session_credentials
          [
            controller.session[session_key],
            controller.session[session_compound_key]
          ].collect { |i| i.nil? ? i : i.to_s }.compact
        end

        # @return [String] - Examples:
        # - user_credentials
        # - ziggity_zack_user_credentials
        #   - ziggity_zack is an "id", see `Authlogic::Session::Id`
        #   - see persistence_token_test.rb
        def session_key
          build_key(self.class.session_key)
        end

        def update_session
          update_session_set_persistence_token
          update_session_set_primary_key
        end

        # Updates the session, setting the primary key (usually `id`) of the
        # record.
        #
        # @api private
        def update_session_set_primary_key
          compound_key = session_compound_key
          controller.session[compound_key] = record && record.send(record.class.primary_key)
        end

        # Updates the session, setting the `persistence_token` of the record.
        #
        # @api private
        def update_session_set_persistence_token
          controller.session[session_key] = record && record.persistence_token
        end
      end
    end
  end
end
