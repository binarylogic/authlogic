# frozen_string_literal: true

module Authlogic
  module ControllerAdapters # :nodoc:
    # Allows you to use Authlogic in any framework you want, not just rails. See
    # the RailsAdapter for an example of how to adapt Authlogic to work with
    # your framework.
    class AbstractAdapter
      E_COOKIE_DOMAIN_ADAPTER = "The cookie_domain method has not been " \
        "implemented by the controller adapter"

      attr_accessor :controller

      def initialize(controller)
        self.controller = controller
      end

      def authenticate_with_http_basic
        @auth = Rack::Auth::Basic::Request.new(controller.request.env)
        if @auth.provided? && @auth.basic?
          yield(*@auth.credentials)
        else
          false
        end
      end

      def cookies
        controller.cookies
      end

      def cookie_domain
        raise NotImplementedError, E_COOKIE_DOMAIN_ADAPTER
      end

      def params
        controller.params
      end

      def request
        controller.request
      end

      def request_content_type
        request.content_type
      end

      def session
        controller.session
      end

      def responds_to_single_access_allowed?
        controller.respond_to?(:single_access_allowed?, true)
      end

      def single_access_allowed?
        controller.send(:single_access_allowed?)
      end

      # You can disable the updating of `last_request_at`
      # on a per-controller basis.
      #
      #   # in your controller
      #   def last_request_update_allowed?
      #     false
      #   end
      #
      # For example, what if you had a javascript function that polled the
      # server updating how much time is left in their session before it
      # times out. Obviously you would want to ignore this request, because
      # then the user would never time out. So you can do something like
      # this in your controller:
      #
      #   def last_request_update_allowed?
      #     action_name != "update_session_time_left"
      #   end
      #
      # See `authlogic/session/magic_columns.rb` to learn more about the
      # `last_request_at` column itself.
      def last_request_update_allowed?
        if controller.respond_to?(:last_request_update_allowed?, true)
          controller.send(:last_request_update_allowed?)
        else
          true
        end
      end

      def respond_to_missing?(*args)
        super(*args) || controller.respond_to?(*args)
      end

      private

      def method_missing(id, *args, &block)
        controller.send(id, *args, &block)
      end
    end
  end
end
