module Authlogic
  # Mixed into `Authlogic::ActsAsAuthentic::Base` and
  # `Authlogic::Session::Foundation`.
  module Config
    def self.extended(klass)
      klass.class_eval do
        # TODO: Is this a confusing name, given this module is mixed into
        # both `Authlogic::ActsAsAuthentic::Base` and
        # `Authlogic::Session::Foundation`? Perhaps a more generic name, like
        # `authlogic_config` would be better?
        class_attribute :acts_as_authentic_config
        self.acts_as_authentic_config ||= {}
      end
    end

    private

    # This is a one-liner method to write a config setting, read the config
    # setting, and also set a default value for the setting.
    def rw_config(key, value, default_value = nil)
      if value.nil?
        acts_as_authentic_config.include?(key) ? acts_as_authentic_config[key] : default_value
      else
        self.acts_as_authentic_config = acts_as_authentic_config.merge(key => value)
        value
      end
    end
  end
end
