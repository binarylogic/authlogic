# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    module Queries
      # @api private
      class CaseSensitivity
        E_UNABLE_TO_DETERMINE_SENSITIVITY = <<~EOS
          Authlogic was unable to determine what case-sensitivity to use when
          searching for email/login. To specify a sensitivity, validate the
          uniqueness of the email/login and use the `case_sensitive` option,
          like this:

              validates :email, uniqueness: { case_sensitive: false }

          Authlogic will now perform a case-insensitive query.
        EOS

        # @api private
        def initialize(model_class, attribute)
          @model_class = model_class
          @attribute = attribute.to_sym
        end

        # @api private
        def sensitive?
          sensitive = uniqueness_validator_options[:case_sensitive]
          if sensitive.nil?
            ::Kernel.warn(E_UNABLE_TO_DETERMINE_SENSITIVITY)
            false
          else
            sensitive
          end
        end

        private

        # @api private
        def uniqueness_validator
          @model_class.validators.select { |v|
            v.is_a?(::ActiveRecord::Validations::UniquenessValidator) &&
              v.attributes == [@attribute]
          }.first
        end

        # @api private
        def uniqueness_validator_options
          uniqueness_validator&.options || {}
        end
      end
    end
  end
end
