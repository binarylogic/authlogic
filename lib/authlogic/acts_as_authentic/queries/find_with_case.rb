# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    module Queries
      # The query used by public-API method `find_by_smart_case_login_field`.
      #
      # We use the rails methods `case_insensitive_comparison` and
      # `case_sensitive_comparison`. These methods nicely take into account
      # MySQL collations. (Consider the case where a user *says* they want a
      # case-sensitive uniqueness validation, but then they configure their
      # database to have an insensitive collation. Rails will handle this for
      # us, by downcasing, see
      # `active_record/connection_adapters/abstract_mysql_adapter.rb`) So that's
      # great! But, these methods are not part of rails' public API, so there
      # are no docs. So, everything we know about how to use the methods
      # correctly comes from mimicing what we find in
      # `active_record/validations/uniqueness.rb`.
      #
      # @api private
      class FindWithCase
        # Dup ActiveRecord.gem_version before freezing, in case someone
        # else wants to modify it. Freezing modifies an object in place.
        # https://github.com/binarylogic/authlogic/pull/590
        AR_GEM_VERSION = ::ActiveRecord.gem_version.dup.freeze

        # @api private
        def initialize(model_class, field, value, sensitive)
          @model_class = model_class
          @field = field.to_s
          @value = value
          @sensitive = sensitive
        end

        # @api private
        def execute
          @model_class.where(comparison).first
        end

        private

        # @api private
        # @return Arel::Nodes::Equality
        def comparison
          @sensitive ? sensitive_comparison : insensitive_comparison
        end

        # @api private
        def insensitive_comparison
          if AR_GEM_VERSION > Gem::Version.new("5.3")
            @model_class.connection.case_insensitive_comparison(
              @model_class.arel_table[@field], @value
            )
          else
            @model_class.connection.case_insensitive_comparison(
              @model_class.arel_table,
              @field,
              @model_class.columns_hash[@field],
              @value
            )
          end
        end

        # @api private
        def sensitive_comparison
          bound_value = @model_class.predicate_builder.build_bind_attribute(@field, @value)
          if AR_GEM_VERSION > Gem::Version.new("5.3")
            @model_class.connection.case_sensitive_comparison(
              @model_class.arel_table[@field], bound_value
            )
          else
            @model_class.connection.case_sensitive_comparison(
              @model_class.arel_table,
              @field,
              @model_class.columns_hash[@field],
              bound_value
            )
          end
        end
      end
    end
  end
end
