# frozen_string_literal: true

module Authlogic
  module Session
    # Responsible for session validation
    #
    # The errors in Authlogic work just like ActiveRecord. In fact, it uses
    # the `ActiveModel::Errors` class. Use it the same way:
    #
    # ```
    # class UserSession
    #   validate :check_if_awesome
    #
    #   private
    #
    #   def check_if_awesome
    #     if login && !login.include?("awesome")
    #       errors.add(:login, "must contain awesome")
    #     end
    #     unless attempted_record.awesome?
    #       errors.add(:base, "You must be awesome to log in")
    #     end
    #   end
    # end
    # ```
    module Validation
      # You should use this as a place holder for any records that you find
      # during validation. The main reason for this is to allow other modules to
      # use it if needed. Take the failed_login_count feature, it needs this in
      # order to increase the failed login count.
      def attempted_record
        @attempted_record
      end

      # See attempted_record
      def attempted_record=(value)
        @attempted_record = value
      end

      # @api public
      def errors
        @errors ||= ::ActiveModel::Errors.new(self)
      end

      # Determines if the information you provided for authentication is valid
      # or not. If there is a problem with the information provided errors will
      # be added to the errors object and this method will return false.
      def valid?
        errors.clear
        self.attempted_record = nil

        before_validation
        new_session? ? before_validation_on_create : before_validation_on_update

        # eg. `Authlogic::Session::Password.validate_by_password`
        # This is when `attempted_record` is set.
        validate

        ensure_authentication_attempted

        if errors.empty?
          new_session? ? after_validation_on_create : after_validation_on_update
          after_validation
        end

        save_record(attempted_record)
        errors.empty?
      end

      private

      def ensure_authentication_attempted
        if errors.empty? && attempted_record.nil?
          errors.add(
            :base,
            I18n.t(
              "error_messages.no_authentication_details",
              default: "You did not provide any details for authentication."
            )
          )
        end
      end
    end
  end
end
