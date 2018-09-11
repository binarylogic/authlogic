# frozen_string_literal: true

class Employee < ActiveRecord::Base
  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::Sha512
  end
  belongs_to :company
end
