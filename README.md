# Authlogic

A clean, simple, and unobtrusive ruby authentication solution.

[![Gem Version][5]][6] [![Build Status][1]][2] [![Code Climate][7]][8] [![Dependency Status][3]][4]

## Documentation

| Version     | Documentation |
| ----------- | ------------- |
| Unreleased  | https://github.com/binarylogic/authlogic/blob/master/README.md |
| 3.5.0       | https://github.com/binarylogic/authlogic/blob/v3.5.0/README.md |
| 2.1.11      | https://github.com/binarylogic/authlogic/blob/v2.1.11/README.md |
| 1.4.3       | https://github.com/binarylogic/authlogic/blob/v1.4.3/README.md |

## Table of Contents

- [1. Introduction](#1-introduction)
  - [1.a. Compatibility](#1a-compatibility)
  - [1.b. Overview](#1b-overview)
  - [1.c. How to use this documentation](#1c-how-to-use-this-documentation)
- [2. Rails](#2-rails)
  - [2.a. The users table](#2a-the-users-table)
  - [2.b. Controller](#2a-controller)
  - [2.c. View](#2c-view)
  - [2.d. CSRF Protection](2d-csrf-protection)
- [3. Testing](#3-testing)
- [4. Helpful links](#4-helpful-links)
- [5. Add-ons](#5-add-ons)
- [6. Internals](#6-internals)

## 1. Introduction

### 1.a. Compatibility

| Version    | branches         | tag     | ruby     | activerecord  |
| ---------- | ---------------- | ------- | -------- | ------------- |
| Unreleased | master, 4-stable |         | >= 2.0.0 | >= 3.2, < 5.1 |
| 3          | 3-stable         | v3.5.0  | >= 1.9.3 | >= 3.2, < 5.1 |
| 2          | rails2           | v2.1.11 | >= 1.9.3 | ~> 2.3.0      |
| 1          | ?                | v1.4.3  | ?        | ?             |

### 1.b. Overview

It introduces a new type of model. You can have as many as you want, and name
them whatever you want, just like your other models. In this example, we want to
authenticate with the User model, which is inferred by the name:

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

``` ruby
session.destroy
```

After a session has been created, you can persist it (i.e. **finding** the
record) across requests. Thus keeping the user logged in:

``` ruby
session = UserSession.find
```

To get all of the nice authentication functionality in your model just do this:

```ruby
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.my_config_option = my_value
  end # the configuration block is optional
end
```

This handles validations, etc. It is also "smart" in the sense that it if a
login field is present it will use that to authenticate, if not it will look for
an email field, etc. This is all configurable, but for 99% of cases that above
is all you will need to do.

You may specify how passwords are cryptographically hashed (or encrypted) by
setting the Authlogic::CryptoProvider option:

``` ruby
c.crypto_provider = Authlogic::CryptoProviders::BCrypt
```

You may validate international email addresses by enabling the provided alternate regex:

``` ruby
c.validates_format_of_email_field_options = {:with => Authlogic::Regex.email_nonascii}
```

Also, sessions are automatically maintained. You can switch this on and off with
configuration, but the following will automatically log a user in after a
successful registration:

``` ruby
User.create(params[:user])
```

You can switch this on and off with the following configuration:

```ruby
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.log_in_after_create = false
  end # the configuration block is optional
end
```

Authlogic also updates the session when the user changes his/her password. You can also switch this on and off with the following configuration:

```ruby
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.log_in_after_password_change = false
  end # the configuration block is optional
end
```

Authlogic is very flexible, it has a strong public API and a plethora of hooks
to allow you to modify behavior and extend it. Check out the helpful links below
to dig deeper.

### 1.c. How to use this documentation

You can find anything you want about Authlogic in the
[documentation](http://rdoc.info/projects/binarylogic/authlogic), all that you
need to do is understand the basic design behind it.

That being said, there are 2 models involved during authentication. Your Authlogic model and your ActiveRecord model:

1. <b>Authlogic::Session</b>, your session models that extend Authlogic::Session::Base.
2. <b>Authlogic::ActsAsAuthentic</b>, which adds in functionality to your ActiveRecord model when you call acts_as_authentic.

Each of the above has its various sub modules that contain common logic. The sub
modules are responsible for including *everything* related to it: configuration,
class methods, instance methods, etc.

For example, if you want to timeout users after a certain period of inactivity,
you would look in <b>Authlogic::Session::Timeout</b>. To help you out, I listed
the following publicly relevant modules with short descriptions. For the sake of
brevity, there are more modules than listed here, the ones not listed are more
for internal use, but you can easily read up on them in the
[documentation](http://rdoc.info/projects/binarylogic/authlogic).

## 2. Rails

What if creating sessions worked like an ORM library on the surface...

``` ruby
UserSession.create(params[:user_session])
```

### 2.a. The users table

If you want to enable all the features of Authlogic, a migration to create a
+User+ model, for example, might look like this:

``` ruby
class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      # Authlogic::ActsAsAuthentic::Email
      t.string    :email

      # Authlogic::ActsAsAuthentic::Password
      t.string    :crypted_password
      t.string    :password_salt

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string    :persistence_token

      # Authlogic::ActsAsAuthentic::SingleAccessToken
      t.string    :single_access_token

      # Authlogic::ActsAsAuthentic::PerishableToken
      t.string    :perishable_token

      # Authlogic::Session::MagicColumns
      t.integer   :login_count, default: 0, null: false
      t.integer   :failed_login_count, default: 0, null: false
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      # Authlogic::Session::MagicStates
      t.boolean   :active, default: false
      t.boolean   :approved, default: false
      t.boolean   :confirmed, default: false

      t.timestamps
    end
  end
end
```

### 2.b. Controller

What if your user sessions controller could look just like your other
controllers?

```ruby
class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    if @user_session.save
      redirect_to account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_url
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password)
  end
end
```

As you can see, this fits nicely into the RESTful development pattern.

How about persisting the session?

```ruby
class ApplicationController
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

### 2.c. View

```erb
<%= form_for @user_session do |f| %>
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

## 3. Testing

See [Authlogic::TestCase](https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/test_case.rb)

## 4. Helpful links

* <b>API Reference:</b> http://rdoc.info/projects/binarylogic/authlogic
* <b>Repository:</b> http://github.com/binarylogic/authlogic/tree/master
* <b>Railscasts Screencast:</b> http://railscasts.com/episodes/160-authlogic
* <b>Example repository with tutorial in README:</b> http://github.com/binarylogic/authlogic_example/tree/master
* <b>Tutorial: Reset passwords with Authlogic the RESTful way:</b> http://www.binarylogic.com/2008/11/16/tutorial-reset-passwords-with-authlogic
* <b>Tutorial</b>: Rails Authentication with Authlogic http://www.sitepoint.com/rails-authentication-with-authlogic
* <b>Issues:</b> http://github.com/binarylogic/authlogic/issues

## 5. Add-ons

* <b>Authlogic OpenID addon:</b> http://github.com/binarylogic/authlogic_openid
* <b>Authlogic LDAP addon:</b> http://github.com/binarylogic/authlogic_ldap
* <b>Authlogic Facebook Connect:</b> http://github.com/kalasjocke/authlogic_facebook_connect
* <b>Authlogic Facebook Connect (New JS API):</b> http://github.com/studybyte/authlogic_facebook_connect
* <b>Authlogic Facebook Shim</b> http://github.com/james2m/authlogic_facebook_shim
* <b>Authlogic OAuth (Twitter):</b> http://github.com/jrallison/authlogic_oauth
* <b>Authlogic Oauth and OpenID:</b> http://github.com/viatropos/authlogic-connect
* <b>Authlogic PAM:</b> http://github.com/nbudin/authlogic_pam
* <b>Authlogic x509:</b> http://github.com/auth-scc/authlogic_x509

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

## Intellectual Property

Copyright (c) 2012 Ben Johnson of Binary Logic, released under the MIT license

[1]: https://api.travis-ci.org/binarylogic/authlogic.svg?branch=master
[2]: https://travis-ci.org/binarylogic/authlogic
[3]: https://gemnasium.com/badges/github.com/binarylogic/authlogic.svg
[4]: https://gemnasium.com/binarylogic/authlogic
[5]: https://badge.fury.io/rb/authlogic.png
[6]: http://badge.fury.io/rb/authlogic
[7]: https://codeclimate.com/github/binarylogic/authlogic.png
[8]: https://codeclimate.com/github/binarylogic/authlogic
