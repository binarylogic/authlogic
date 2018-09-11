# frozen_string_literal: true

module Authlogic
  module Session
    module MagicColumn
      # Assigns the current time to the `last_request_at` attribute.
      #
      # 1. The `last_request_at` column must exist
      # 2. Assignment can be disabled on a per-controller basis
      # 3. Assignment will not happen more often than `last_request_at_threshold`
      #   seconds.
      #
      # - current_time - a `Time`
      # - record - eg. a `User`
      # - controller - an `Authlogic::ControllerAdapters::AbstractAdapter`
      # - last_request_at_threshold - integer - seconds
      #
      # @api private
      class AssignsLastRequestAt
        def initialize(current_time, record, controller, last_request_at_threshold)
          @current_time = current_time
          @record = record
          @controller = controller
          @last_request_at_threshold = last_request_at_threshold
        end

        def assign
          return unless assign?
          @record.last_request_at = @current_time
        end

        private

        # @api private
        def assign?
          @record &&
            @record.class.column_names.include?("last_request_at") &&
            @controller.last_request_update_allowed? && (
              @record.last_request_at.blank? ||
              @last_request_at_threshold.to_i.seconds.ago >= @record.last_request_at
            )
        end
      end
    end
  end
end
