# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    module Queries
      # The query used by public-API method `find_by_smart_case_login_field`.
      # @api private
      class FindWithCase
        AR_GEM_VERSION = ActiveRecord.gem_version.freeze

        # @api private
        def initialize(model_class, field, value, sensitive)
          @model_class = model_class
          @field = field.to_s
          @value = value
          @sensitive = sensitive
        end

        # @api private
        def execute
          bind(relation).first
        end

        private

          # @api private
          def bind(relation)
            if AR_GEM_VERSION >= Gem::Version.new('5')
              bind = ActiveRecord::Relation::QueryAttribute.new(
                @field,
                @value,
                ActiveRecord::Type::Value.new
              )
              @model_class.where(relation, bind)
            else
              @model_class.where(relation)
            end
          end

          # @api private
          def relation
            if !@sensitive
              @model_class.connection.case_insensitive_comparison(
                @model_class.arel_table,
                @field,
                @model_class.columns_hash[@field],
                @value
              )
            elsif AR_GEM_VERSION >= Gem::Version.new('5.0')
              @model_class.connection.case_sensitive_comparison(
                @model_class.arel_table,
                @field,
                @model_class.columns_hash[@field],
                @value
              )
            else
              value = @model_class.connection.case_sensitive_modifier(@value, @field)
              @model_class.arel_table[@field].eq(value)
            end
          end
      end
    end
  end
end
