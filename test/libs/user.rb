class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_crypto_providers Authlogic::CryptoProviders::Sha512
  end
  belongs_to :company
  has_and_belongs_to_many :projects
end
