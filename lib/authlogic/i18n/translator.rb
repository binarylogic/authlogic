# frozen_string_literal: true

module Authlogic
  module I18n
    # The default translator used by authlogic/i18n.rb
    class Translator
      # If the I18n gem is present, calls +I18n.translate+ passing all
      # arguments, else returns +options[:default]+.
      def translate(key, options = {})
        if defined?(::I18n)
          ::I18n.translate key, **options
        else
          options[:default]
        end
      end
    end
  end
end
