# frozen_string_literal: true

module Authlogic
  # Mixed into `Authlogic::ActsAsAuthentic::Base` and
  # `Authlogic::Session::Base`.
  module Config
    E_USE_NORMAL_RAILS_VALIDATION = <<~EOS
      This Authlogic configuration option (%s) is deprecated. Use normal
      ActiveRecord validation instead. Detailed instructions:
      https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
    EOS

    def self.extended(klass)
      klass.class_eval do
        # TODO: Is this a confusing name, given this module is mixed into
        # both `Authlogic::ActsAsAuthentic::Base` and
        # `Authlogic::Session::Base`? Perhaps a more generic name, like
        # `authlogic_config` would be better?
        class_attribute :acts_as_authentic_config
        self.acts_as_authentic_config ||= {}
      end
    end

    private

    def deprecate_authlogic_config(method_name)
      ::ActiveSupport::Deprecation.warn(
        format(E_USE_NORMAL_RAILS_VALIDATION, method_name)
      )
    end

    # This is a one-liner method to write a config setting, read the config
    # setting, and also set a default value for the setting.
    def rw_config(key, value, default_value = nil)
      value.nil? ? read_config(key, default_value) : write_config(key, value)
    end

    # Read a value for a key.
    def read_config(key, default)
      return acts_as_authentic_config[key] if acts_as_authentic_config.include?(key)

      return default.call if default.respond_to? :call

      default
    end

    # Write a value for a key and return that value.
    def write_config(key, value)
      self.acts_as_authentic_config = acts_as_authentic_config.merge(key => value)

      value
    end
  end
end
