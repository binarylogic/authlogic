# Use Normal ActiveRecord Validation

In Authlogic 4.4.0, [we deprecated][1] the features of Authlogic related to
validating email, login, and password. In 5.0.0 these features will be dropped.
Use normal ActiveRecord validations instead.

## Instructions for 4.4.0

First, disable the deprecated Authlogic validations:

    acts_as_authentic do |c|
      c.validate_email_field = false
      c.validate_login_field = false
      c.validate_password_field = false
    end

Then, use normal ActiveRecord validations instead. For example, instead of
the Authlogic method validates_length_of_email_field_options, use

    validates :email, length: { ... }

It might be a good idea to replace these one field at a time, ie. email,
then login, then password; one field per commit.

Finish this process before upgrading to Authlogic 5.

## Default Values

The following validations represent the defaults in Authlogic 4. Merge these
defaults with any settings you may have overwritten.

```ruby
EMAIL = /
  \A
  [A-Z0-9_.&%+\-']+   # mailbox
  @
  (?:[A-Z0-9\-]+\.)+  # subdomains
  (?:[A-Z]{2,25})     # TLD
  \z
/ix
LOGIN = /\A[a-zA-Z0-9_][a-zA-Z0-9\.+\-_@ ]+\z/

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
```

## Motivation

The deprecated features save people some time in the beginning, when setting up
Authlogic. But, later in the life of a project, when these settings need to
change, it is obscure compared to normal ActiveRecord validations.

[1]: https://github.com/binarylogic/authlogic/pull/623
