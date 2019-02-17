# Use Normal ActiveRecord Validation

In Authlogic 4.4.0, [we deprecated][1] the features of Authlogic related to
validating email, login, and password. In 5.0.0 these features will be dropped.
Use normal ActiveRecord validations instead.

## Instructions

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

## Default Values

The following validations represent the Authlogic < 5 defaults. Merge these
defaults with any settings you may have overwritten.

```
validates :email,
  format: {
    with: ::Authlogic::Regex::EMAIL,
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
    if: :email_changed?
  }

validates :login,
  format: {
    with: ::Authlogic::Regex::LOGIN,
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
    if: :login_changed?
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

The deprecated features save people some time in the begginning, when setting up
Authlogic. But, later in the life of a project, when these settings need to
change, it is obscure compared to normal ActiveRecord validations.

[1]: https://github.com/binarylogic/authlogic/pull/623
