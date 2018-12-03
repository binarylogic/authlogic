# frozen_string_literal: true

class User < ActiveRecord::Base
  EMAIL = /
    \A
    [A-Z0-9_.&%+\-']+   # mailbox
    @
    (?:[A-Z0-9\-]+\.)+  # subdomains
    (?:[A-Z]{2,25})     # TLD
    \z
  /ix
  LOGIN = /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/

  acts_as_authentic do |c|
    c.transition_from_crypto_providers Authlogic::CryptoProviders::Sha512
  end
  belongs_to :company
  has_and_belongs_to_many :projects

  # Validations
  # -----------
  #
  # In Authlogic 4.4.0, we deprecated the features of Authlogic related to
  # validating email, login, and password. In 5.0.0 these features were dropped.
  # People will instead use normal ActiveRecord validations.
  #
  # The following validations represent what Authlogic < 5 used as defaults.
  validates :email,
    format: {
      with: EMAIL,
      message: proc {
        ::Authlogic::I18n.t(
          "error_messages.email_invalid",
          default: "should look like an email address."
        )
      }
    },
    length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_email?
    }

  validates :login,
    format: {
      with: LOGIN,
      message: proc {
        ::Authlogic::I18n.t(
          "error_messages.login_invalid",
          default: "should use only letters, numbers, spaces, and .-_@+ please."
        )
      }
    },
    length: { within: 3..100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_login?
    }

  validates :password,
    confirmation: { if: :require_password? },
    length: {
      minimum: 8,
      if: :require_password?
    }
  validates :password_confirmation,
    length: {
      minimum: 8,
      if: :require_password?
    }
end
