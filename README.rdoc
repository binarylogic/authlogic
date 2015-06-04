= Authlogic

** Authlogic supports both rails 3 and 4. For rails 2, see the rail2 branch

{<img src="https://travis-ci.org/binarylogic/authlogic.svg?branch=master" alt="Build Status" />}[https://travis-ci.org/binarylogic/authlogic]

{<img src="https://codeclimate.com/github/binarylogic/authlogic.png" />}[https://codeclimate.com/github/binarylogic/authlogic]

Authlogic is a clean, simple, and unobtrusive ruby authentication solution.

A code example can replace a thousand words...

Authlogic introduces a new type of model. You can have as many as you want, and name them whatever you want, just like your other models. In this example, we want to authenticate with the User model, which is inferred by the name:

  class UserSession < Authlogic::Session::Base
    # specify configuration here, such as:
    # logout_on_timeout true
    # ...many more options in the documentation
  end

Log in with any of the following. Create a UserSessionsController and use it just like your other models:

  UserSession.create(:login => "bjohnson", :password => "my password", :remember_me => true)
  session = UserSession.new(:login => "bjohnson", :password => "my password", :remember_me => true); session.save
  UserSession.create(:openid_identifier => "identifier", :remember_me => true) # requires the authlogic-oid "add on" gem
  UserSession.create(my_user_object, true) # skip authentication and log the user in directly, the true means "remember me"

The above handles the entire authentication process for you. It first authenticates, then it sets up the proper session values and cookies to persist the session. Just like you would if you rolled your own authentication solution.

You can also log out / destroy the session:

  session.destroy

After a session has been created, you can persist it across requests. Thus keeping the user logged in:

  session = UserSession.find

To get all of the nice authentication functionality in your model just do this:

  class User < ActiveRecord::Base
    acts_as_authentic do |c|
      c.my_config_option = my_value
    end # the configuration block is optional
  end

This handles validations, etc. It is also "smart" in the sense that it if a login field is present it will use that to authenticate, if not it will look for an email field, etc. This is all configurable, but for 99% of cases that above is all you will need to do.

You may specify how passwords are cryptographically hashed (or encrypted) by setting the Authlogic::CryptoProvider option:

  c.crypto_provider = Authlogic::CryptoProviders::BCrypt

You may validate international email addresses by enabling the provided alternate regex:

  c.validates_format_of_email_field_options = {:with => Authlogic::Regex.email_nonascii}

Also, sessions are automatically maintained. You can switch this on and off with configuration, but the following will automatically log a user in after a successful registration:

  User.create(params[:user])

This also updates the session when the user changes his/her password.

Authlogic is very flexible, it has a strong public API and a plethora of hooks to allow you to modify behavior and extend it. Check out the helpful links below to dig deeper.

== Upgrading to Authlogic 3.4.0

In version 3.4.0, the default crypto_provider was changed from *Sha512* to *SCrypt*.

If you never set a crypto_provider and are upgrading, your passwords will break unless you set the original:

  c.crypto_provider = Authlogic::CryptoProviders::Sha512

And if you want to automatically upgrade from *Sha512* to *SCrypt* as users login:

  c.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
  c.crypto_provider = Authlogic::CryptoProviders::SCrypt

== Helpful links

* <b>Documentation:</b> http://rdoc.info/projects/binarylogic/authlogic
* <b>Repository:</b> http://github.com/binarylogic/authlogic/tree/master
* <b>Railscasts Screencast:</b> http://railscasts.com/episodes/160-authlogic
* <b>Example repository with tutorial in README:</b> http://github.com/binarylogic/authlogic_example/tree/master
* <b>Tutorial: Reset passwords with Authlogic the RESTful way:</b> http://www.binarylogic.com/2008/11/16/tutorial-reset-passwords-with-authlogic
* <b>Issues:</b> http://github.com/binarylogic/authlogic/issues

== Authlogic "add ons"

* <b>Authlogic OpenID addon:</b> http://github.com/binarylogic/authlogic_openid
* <b>Authlogic LDAP addon:</b> http://github.com/binarylogic/authlogic_ldap
* <b>Authlogic Facebook Connect:</b> http://github.com/kalasjocke/authlogic_facebook_connect
* <b>Authlogic Facebook Connect (New JS API):</b> http://github.com/studybyte/authlogic_facebook_connect
* <b>Authlogic Facebook Shim</b> http://github.com/james2m/authlogic_facebook_shim
* <b>Authlogic OAuth (Twitter):</b> http://github.com/jrallison/authlogic_oauth
* <b>Authlogic Oauth and OpenID:</b> http://github.com/viatropos/authlogic-connect
* <b>Authlogic PAM:</b> http://github.com/nbudin/authlogic_pam
* <b>Authlogic x509:</b> http://github.com/auth-scc/authlogic_x509

If you create one of your own, please let me know about it so I can add it to this list. Or just fork the project, add your link, and send me a pull request.

== Documentation explanation

You can find anything you want about Authlogic in the {documentation}[http://rdoc.info/projects/binarylogic/authlogic], all that you need to do is understand the basic design behind it.

That being said, there are 2 models involved during authentication. Your Authlogic model and your ActiveRecord model:

1. <b>Authlogic::Session</b>, your session models that extend Authlogic::Session::Base.
2. <b>Authlogic::ActsAsAuthentic</b>, which adds in functionality to your ActiveRecord model when you call acts_as_authentic.

Each of the above has its various sub modules that contain common logic. The sub modules are responsible for including *everything* related to it: configuration, class methods, instance methods, etc.

For example, if you want to timeout users after a certain period of inactivity, you would look in <b>Authlogic::Session::Timeout</b>. To help you out, I listed the following publicly relevant modules with short descriptions. For the sake of brevity, there are more modules than listed here, the ones not listed are more for internal use, but you can easily read up on them in the {documentation}[http://rdoc.info/projects/binarylogic/authlogic].

== Example migration

If you want to enable all the features of Authlogic, a migration to create a
+User+ model, for example, might look like this:

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

== Quick Rails example

What if creating sessions worked like an ORM library on the surface...

  UserSession.create(params[:user_session])

What if your user sessions controller could look just like your other controllers...

  class UserSessionsController < ApplicationController
    def new
      @user_session = UserSession.new
    end

    def create
      @user_session = UserSession.new(params[:user_session])
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
  end

As you can see, this fits nicely into the RESTful development pattern. What about the view...

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

Or how about persisting the session...

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

== Testing

See Authlogic::TestCase

== Tell me quickly how Authlogic works

Interested in how all of this all works? Think about an ActiveRecord model. A database connection must be established before you can use it. In the case of Authlogic, a controller connection must be established before you can use it. It uses that controller connection to modify cookies, the current session, login with HTTP basic, etc. It connects to the controller through a before filter that is automatically set in your controller which lets Authlogic know about the current controller object. Then Authlogic leverages that to do everything, it's a pretty simple design. Nothing crazy going on, Authlogic is just leveraging the tools your framework provides in the controller object.


Copyright (c) 2012 {Ben Johnson of Binary Logic}[http://www.binarylogic.com], released under the MIT license
