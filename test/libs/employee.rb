# frozen_string_literal: true

class Employee < ActiveRecord::Base
  acts_as_authentic do |config|
    silence_warnings do
      config.crypto_provider = Authlogic::CryptoProviders::Sha512
    end
  end
  belongs_to :company
end
