# frozen_string_literal: true

# This model demonstrates an `after_save` callback.
class Admin < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  validates :password, confirmation: true

  after_save do
    # In rails 5.1 `role_changed?` was deprecated in favor of `saved_change_to_role?`.
    #
    # > DEPRECATION WARNING: The behavior of `attribute_changed?` inside of
    # > after callbacks will be changing in the next version of Rails.
    # > The new return value will reflect the behavior of calling the method
    # > after `save` returned (e.g. the opposite of what it returns now). To
    # > maintain the current behavior, use `saved_change_to_attribute?` instead.
    #
    # So, in rails >= 5.2, we must use `saved_change_to_role?`.
    if saved_change_to_role?
      reset_password!
    end
  end
end
