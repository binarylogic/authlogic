# Authlogic

An unobtrusive ruby authentication library based on ActiveRecord.

[![Gem Version][5]][6] [![Build Status][1]][2] [![Code Climate][7]][8] [![Dependency Status][3]][4]

[![Coverage Status](https://coveralls.io/repos/github/binarylogic/authlogic/badge.svg?branch=master)](https://coveralls.io/github/binarylogic/authlogic?branch=master)

## Documentation

| Version    | Documentation                                                     |
| ---------- | ----------------------------------------------------------------- |
| Unreleased | https://github.com/binarylogic/authlogic/blob/master/README.md    |
| 6.5.0      | https://github.com/binarylogic/authlogic/blob/v6.5.0/README.md    |
| 6.4.3      | https://github.com/binarylogic/authlogic/blob/v6.4.3/README.md    |
| 5.2.0      | https://github.com/binarylogic/authlogic/blob/v5.2.0/README.md    |
| 4.5.0      | https://github.com/binarylogic/authlogic/blob/v4.5.0/README.md    |
| 3.7.0      | https://github.com/binarylogic/authlogic/blob/v3.7.0/README.md    |
| 2.1.11     | https://github.com/binarylogic/authlogic/blob/v2.1.11/README.rdoc |
| 1.4.3      | https://github.com/binarylogic/authlogic/blob/v1.4.3/README.rdoc  |

## Table of Contents

- [1. Introduction](#1-introduction)
  - [1.a. Overview](#1a-overview)
  - [1.b. Reference Documentation](#1b-reference-documentation)
  - [1.c. Installation](#1c-installation)
- [2. Rails](#2-rails)
  - [2.a. The users table](#2a-the-users-table)
  - [2.b. Controller](#2b-controller)
    - [2.b.1. Helper Methods](#2b1-helper-methods)
    - [2.b.2. Routes](#2b2-routes)
    - [2.b.3. ActionController::API](#2b3-actioncontroller-api)
  - [2.c. View](#2c-view)
  - [2.d. CSRF Protection](#2d-csrf-protection)
- [3. Testing](#3-testing)
- [4. Helpful links](#4-helpful-links)
- [5. Add-ons](#5-add-ons)
- [6. Internals](#6-internals)
- [7. Extending](#7-extending)
- [90. Compatibility](#90-compatibility)

## 1. Introduction

### 1.a. Overview

Authlogic introduces a new type of model. You can have as many as you want, and
name them whatever you want, just like your other models. In this example, we
want to authenticate with our `User` model, which is inferred from the name:

```ruby
class UserSession < Authlogic::Session::Base
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation
end
```

In a `UserSessionsController`, login the user by using it just like your other models:

```ruby
UserSession.create(:login => "bjohnson", :password => "my password", :remember_me => true)

session = UserSession.new(:login => "bjohnson", :password => "my password", :remember_me => true)
session.save

# requires the authlogic-oid "add on" gem
UserSession.create(:openid_identifier => "identifier", :remember_me => true)

# skip authentication and log the user in directly, the true means "remember me"
UserSession.create(my_user_object, true)
```

The above handles the entire authentication process for you by:

1. authenticating (i.e. **validating** the record)
2. sets up the proper session values and cookies to persist the session (i.e. **saving** the record).

You can also log out (i.e. **destroying** the session):

```ruby
session.destroy
```

After a session has been created, you can persist it (i.e. **finding** the
record) across requests. Thus keeping the user logged in:

```ruby
session = UserSession.find
```

To get all of the nice authentication functionality in your model just do this:

```ruby
class User < ApplicationRecord
  acts_as_authentic do |c|
    c.my_config_option = my_value
  end # the configuration block is optional
end
```

It is also "smart" in the sense that if a login or username field
is present it will use that to authenticate, if not it will look for
an email field. This is all configurable, but for 99% of cases the above
is all you will need to do.

You may specify how passwords are cryptographically hashed (or encrypted) by
setting the Authlogic::CryptoProvider option:

```ruby
c.crypto_provider = Authlogic::CryptoProviders::BCrypt
```

Also, sessions are automatically maintained. You can switch this on and off with
configuration, but the following will automatically log a user in after a
successful registration:

```ruby
User.create(params[:user])
```

You can switch this on and off with the following configuration:

```ruby
class User < ApplicationRecord
  acts_as_authentic do |c|
    c.log_in_after_create = false
  end # the configuration block is optional
end
```

Authlogic also updates the session when the user changes his/her password. You can also switch this on and off with the following configuration:

```ruby
class User < ApplicationRecord
  acts_as_authentic do |c|
    c.log_in_after_password_change = false
  end # the configuration block is optional
end
```

Authlogic is very flexible, it has a strong public API and a plethora of hooks
to allow you to modify behavior and extend it. Check out the helpful links below
to dig deeper.

### 1.b. Reference Documentation

This README is just an introduction, but we also have [reference
documentation](http://www.rubydoc.info/github/binarylogic/authlogic).

**To use the reference documentation, you must understand how Authlogic's
code is organized.** There are 2 models, your Authlogic model and your
ActiveRecord model:

1. **Authlogic::Session**, your session models that
   extend `Authlogic::Session::Base`.
2. **Authlogic::ActsAsAuthentic**, which adds in functionality to your
   ActiveRecord model when you call `acts_as_authentic`.

### 1.c. Installation

To install Authlogic, add this to your Gemfile:

`gem 'authlogic'`

And run `bundle install`.

## 2. Rails

Let's walk through a typical rails setup. ([Compatibility](#90-compatibility))

### 2.a.1 The users table

If you want to enable all the features of Authlogic, a migration to create a
`User` model might look like this:

```ruby
class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # Authlogic::ActsAsAuthentic::Email
      t.string    :email
      t.index     :email, unique: true

      # Authlogic::ActsAsAuthentic::Login
      t.string    :login

      # Authlogic::ActsAsAuthentic::Password
      t.string    :crypted_password
      t.string    :password_salt

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string    :persistence_token
      t.index     :persistence_token, unique: true

      # Authlogic::ActsAsAuthentic::SingleAccessToken
      t.string    :single_access_token
      t.index     :single_access_token, unique: true

      # Authlogic::ActsAsAuthentic::PerishableToken
      t.string    :perishable_token
      t.index     :perishable_token, unique: true

      # See "Magic Columns" in Authlogic::Session::Base
      t.integer   :login_count, default: 0, null: false
      t.integer   :failed_login_count, default: 0, null: false
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      # See "Magic States" in Authlogic::Session::Base
      t.boolean   :active, default: false
      t.boolean   :approved, default: false
      t.boolean   :confirmed, default: false

      t.timestamps
    end
  end
end
```

In the `User` model,

```ruby
class User < ApplicationRecord
  acts_as_authentic

  # Validate email, login, and password as you see fit.
  #
  # Authlogic < 5 added these validation for you, making them a little awkward
  # to change. In 4.4.0, those automatic validations were deprecated. See
  # https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
  validates :email,
    format: {
      with: /@/,
      message: "should look like an email address."
    },
    length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      if: :will_save_change_to_email?
    }

  validates :login,
    format: {
      with: /\A[a-z0-9]+\z/,
      message: "should use only letters and numbers."
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
```

### 2.a.2. UserSession model

And define a corresponding model in `app/models/user_session.rb`:

```ruby
class UserSession < Authlogic::Session::Base
end
```

### 2.b. Controller

Your sessions controller will look just like your other controllers.

```ruby
class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)
    if @user_session.save
      redirect_to root_url
    else
      render :new, status: 422
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_url
  end

  private

  def user_session_params
    params.require(:user_session).permit(:login, :password, :remember_me)
  end
end
```

As you can see, this fits nicely into the [conventional controller methods][9].

#### 2.b.1. Helper Methods

```ruby
class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
end
```

#### 2.b.2. Routes

```ruby
Rails.application.routes.draw do
  # ...
  resources :users
  resource :user_session
end
```

#### 2.b.3. ActionController::API

> Because ActionController::API does not include ActionController::Cookies
> metal and ActionDispatch::Cookies rack module, Therefore, our controller can
> not use the cookies method.
>
> - [#684](https://github.com/binarylogic/authlogic/pull/684).

### 2.c. View

For example, in `app/views/user_sessions/new.html.erb`:

```erb
<%= form_for @user_session, url: user_session_url do |f| %>
  <% if @user_session.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@user_session.errors.count, "error") %> prohibited:</h2>
    <ul>
      <% @user_session.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
    </ul>
  </div>
  <% end %>
  <%= f.label :login %><br />
  <%= f.text_field :login %><br />
  <br />
  <%= f.label :password %><br />
  <%= f.password_field :password %><br />
  <br />
  <%= f.label :remember_me %><br />
  <%= f.check_box :remember_me %><br />
  <br />
  <%= f.submit "Login" %>
<% end %>
```

### 2.d. CSRF Protection

Because Authlogic introduces its own methods for storing user sessions, the CSRF
(Cross Site Request Forgery) protection that is built into Rails will not work
out of the box.

No generally applicable mitigation by the authlogic library is possible, because
the instance variable you use to store a reference to the user session in `def
current_user_session` will not be known to authlogic.

You will need to override `ActionController::Base#handle_unverified_request` to
do something appropriate to how your app handles user sessions, e.g.:

```ruby
class ApplicationController < ActionController::Base
  ...
  protected

  def handle_unverified_request
    # raise an exception
    fail ActionController::InvalidAuthenticityToken
    # or destroy session, redirect
    if current_user_session
      current_user_session.destroy
    end
    redirect_to root_url
  end
end
```

### 2.e. SameSite Cookie Attribute

The SameSite attribute tells browsers when and how to fire cookies in first- or third-party situations. SameSite is used by a variety of browsers to identify whether or not to allow a cookie to be accessed.

Up until recently, the standard default value when SameSite was not explicitly defined was to allow cookies in both first- and third-party contexts. However, starting with Chrome 80+, the SameSite attribute will not default to Lax behavior meaning cookies will only be permitted in first-party contexts.

Authlogic can allow you to explicitly set the value of SameSite to one of: Lax, Strict, or None. Note that when setting SameSite to None, the `secure` flag must also be set (secure is the default in Authlogic).

Reference: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#SameSite

## 3. Testing

See [Authlogic::TestCase](https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/test_case.rb)

## 4. Helpful links

- <b>API Reference:</b> http://www.rubydoc.info/github/binarylogic/authlogic
- <b>Repository:</b> https://github.com/binarylogic/authlogic/tree/master
- <b>Railscasts Screencast:</b> http://railscasts.com/episodes/160-authlogic
- <b>Example repository with tutorial in README:</b> https://github.com/binarylogic/authlogic_example/tree/master
- <b>Tutorial</b>: Rails Authentication with Authlogic https://www.sitepoint.com/rails-authentication-with-authlogic
- <b>Issues:</b> https://github.com/binarylogic/authlogic/issues
- <b>Chrome is not logging out on browser close</b> https://productforums.google.com/forum/#!topic/chrome/9l-gKYIUg50/discussion

## 5. Add-ons

- <b>Authlogic OpenID addon:</b> https://github.com/binarylogic/authlogic_openid
- <b>Authlogic LDAP addon:</b> https://github.com/binarylogic/authlogic_ldap
- <b>Authlogic Facebook Connect:</b> https://github.com/kalasjocke/authlogic-facebook-connect
- <b>Authlogic Facebook Connect (New JS API):</b> https://github.com/studybyte/authlogic_facebook_connect
- <b>Authlogic Facebook Shim</b> https://github.com/james2m/authlogic_facebook_shim
- <b>Authlogic OAuth (Twitter):</b> https://github.com/jrallison/authlogic_oauth
- <b>Authlogic Oauth and OpenID:</b> https://github.com/lancejpollard/authlogic-connect
- <b>Authlogic PAM:</b> https://github.com/nbudin/authlogic_pam
- <b>Authlogic x509:</b> https://github.com/auth-scc/authlogic_x509

If you create one of your own, please let us know about it so we can add it to
this list. Or just fork the project, add your link, and send us a pull request.

## 6. Internals

Interested in how all of this all works? Think about an ActiveRecord model. A
database connection must be established before you can use it. In the case of
Authlogic, a controller connection must be established before you can use it. It
uses that controller connection to modify cookies, the current session, login
with HTTP basic, etc. It connects to the controller through a before filter that
is automatically set in your controller which lets Authlogic know about the
current controller object. Then Authlogic leverages that to do everything, it's
a pretty simple design. Nothing crazy going on, Authlogic is just leveraging the
tools your framework provides in the controller object.

## 7. Extending

## 7.a. Extending UserSession

Your `UserSession` is designed to be extended with callbacks.

Example: Custom logging.

```
# user_session.rb
class UserSession < Authlogic::Session::Base
  after_persisting :my_custom_logging

  private

  def my_custom_logging
    Rails.logger.info(
      format(
        'After authentication attempt, user id is %d',
        record.send(record.class.primary_key)
      )
    )
  end
end
```

To learn more about available callbacks, see the "Callbacks" documentation
in `authlogic/session/base.rb`.

## 90. Compatibility

| Version | branch     | ruby     | activerecord  |
| ------- | ---------- | -------- | ------------- |
| 6.5.0   | 6-5-stable | >= 2.4.0 | >= 5.2, < 8.0 |
| 6.4.3   | 6-4-stable | >= 2.4.0 | >= 5.2, < 7.1 |
| 5.2     | 5-2-stable | >= 2.3.0 | >= 5.2, < 6.1 |
| 4.5     | 4-5-stable | >= 2.3.0 | >= 4.2, < 5.3 |
| 4.3     | 4-3-stable | >= 2.3.0 | >= 4.2, < 5.3 |
| 4.2     | 4-2-stable | >= 2.2.0 | >= 4.2, < 5.3 |
| 3       | 3-stable   | >= 1.9.3 | >= 3.2, < 5.3 |
| 2       | rails2     | >= 1.9.3 | ~> 2.3.0      |
| 1       | ?          | ?        | ?             |

Under SemVer, [changes to dependencies][10] do not require a major release.

## Intellectual Property

Copyright (c) 2012 Ben Johnson of Binary Logic, released under the MIT license

[1]: https://api.travis-ci.org/binarylogic/authlogic.svg?branch=master
[2]: https://travis-ci.org/binarylogic/authlogic
[3]: https://gemnasium.com/badges/github.com/binarylogic/authlogic.svg
[4]: https://gemnasium.com/binarylogic/authlogic
[5]: https://badge.fury.io/rb/authlogic.svg
[6]: http://badge.fury.io/rb/authlogic
[7]: https://codeclimate.com/github/binarylogic/authlogic.svg
[8]: https://codeclimate.com/github/binarylogic/authlogic
[9]: http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default
[10]: https://semver.org/spec/v2.0.0.html#what-should-i-do-if-i-update-my-own-dependencies-without-changing-the-public-api
