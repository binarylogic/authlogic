# frozen_string_literal: true

module Authlogic
  module Session
    # This module supports ActiveRecord's optimistic locking feature, which is
    # automatically enabled when a table has a `lock_version` column.
    #
    # ```
    # # https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html
    # p1 = Person.find(1)
    # p2 = Person.find(1)
    # p1.first_name = "Michael"
    # p1.save
    # p2.first_name = "should fail"
    # p2.save # Raises an ActiveRecord::StaleObjectError
    # ```
    #
    # Now, consider the following Authlogic scenario:
    #
    # ```
    # User.log_in_after_password_change = true
    # ben = User.find(1)
    # UserSession.create(ben)
    # ben.password = "newpasswd"
    # ben.password_confirmation = "newpasswd"
    # ben.save
    # ```
    #
    # We've used one of Authlogic's session maintenance features,
    # `log_in_after_password_change`. So, when we call `ben.save`, there is a
    # `before_save` callback that logs Ben in (`UserSession.find`). Well, when
    # we log Ben in, we update his user record, eg. `login_count`. When we're
    # done logging Ben in, then the normal `ben.save` happens. So, there were
    # two `update` queries. If those two updates came from different User
    # instances, we would get a `StaleObjectError`.
    #
    # Our solution is to carefully pass around a single `User` instance, using
    # it for all `update` queries, thus avoiding the `StaleObjectError`.
    #
    # TODO: Perhaps this file should be merged into `session/persistence.rb`
    #
    # @api private
    module PriorityRecord
      # @api private
      def self.included(klass)
        klass.class_eval do
          attr_accessor :priority_record
        end
      end

      # Setting priority record if it is passed. The only way it can be passed
      # is through an array:
      #
      #   session.credentials = [real_user_object, priority_user_object]
      #
      # @api private
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        self.priority_record = values[1] if values[1].class < ::ActiveRecord::Base
      end

      private

      # @api private
      def attempted_record=(value)
        value = priority_record if value == priority_record
        super
      end

      # @api private
      def save_record(alternate_record = nil)
        r = alternate_record || record
        super if r != priority_record
      end
    end
  end
end
