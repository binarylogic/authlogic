# frozen_string_literal: true

class Admin < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_crypto_providers Authlogic::CryptoProviders::Sha512
  end

  after_save do
    if saved_change_to_role?
      reset_password!
    end
  end

  after_save do
    if saved_change_to_crypted_password
      reset_perishable_token!
    end
  end

  def reset_password!
    self.password = "1#{SecureRandom.hex}a"
    save!
  end
end
