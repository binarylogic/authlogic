module Authlogic
  module ActsAsAuthentic
    # Allows you to scope everything to specific fields.
    # See the Config submodule for more info.
    # For information on how to scope off of a parent object see Authlogic::AuthenticatesMany
    module Scope
      # All configuration for the scope feature.
      module Config
        # Allows you to scope everything to specific field(s). Works just like validates_uniqueness_of.
        # For example, let's say a user belongs to a company, and you want to scope everything to the
        # company:
        #
        #   acts_as_authentic do |c|
        #     c.scope = :company_id
        #   end
        #
        # * <tt>Default:</tt> nil
        # * <tt>Accepts:</tt> Symbol or Array of symbols
        def scope(value = nil)
          config(:scope, value)
        end
        alias_method :scope=, :scope
      end
    end
  end
end