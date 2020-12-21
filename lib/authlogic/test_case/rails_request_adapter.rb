# frozen_string_literal: true

module Authlogic
  module TestCase
    # Adapts authlogic to work with the @request object when testing. This way Authlogic
    # can set cookies and what not before a request is made, ultimately letting you log in
    # users in functional tests.
    class RailsRequestAdapter < ControllerAdapters::AbstractAdapter
      def authenticate_with_http_basic(&block)
      end

      def cookies
        new_cookies = MockCookieJar.new
        super.each do |key, value|
          new_cookies[key] = cookie_value(value)
        end
        new_cookies
      end

      def cookie_domain
        nil
      end

      def request
        @request ||= MockRequest.new(controller)
      end

      def request_content_type
        request.format.to_s
      end

      private

      def cookie_value(value)
        value.is_a?(Hash) ? value[:value] : value
      end
    end
  end
end
