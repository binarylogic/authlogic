# frozen_string_literal: true

require "request_store"

module Authlogic
  module Session
    module Activation
      # :nodoc:
      class NotActivatedError < ::StandardError
        def initialize
          super(
            "You must activate the Authlogic::Session::Base.controller with " \
                "a controller object before creating objects"
          )
        end
      end
    end

    module Existence
      # :nodoc:
      class SessionInvalidError < ::StandardError
        def initialize(session)
          message = I18n.t(
            "error_messages.session_invalid",
            default: "Your session is invalid and has the following errors:"
          )
          message += " #{session.errors.full_messages.to_sentence}"
          super message
        end
      end
    end

    # This is the most important class in Authlogic. You will inherit this class
    # for your own eg. `UserSession`.
    #
    # Ongoing consolidation of modules
    # ================================
    #
    # We are consolidating modules into this class (inlining mixins). When we
    # are done, there will only be this one file. It will be quite large, but it
    # will be easier to trace execution.
    #
    # Once consolidation is complete, we hope to identify and extract
    # collaborating objects. For example, there may be a "session adapter" that
    # connects this class with the existing `ControllerAdapters`. Perhaps a
    # data object or a state machine will reveal itself.
    #
    # Activation
    # ==========
    #
    # Activating Authlogic requires that you pass it an
    # Authlogic::ControllerAdapters::AbstractAdapter object, or a class that
    # extends it. This is sort of like a database connection for an ORM library,
    # Authlogic can't do anything until it is "connected" to a controller. If
    # you are using a supported framework, Authlogic takes care of this for you.
    #
    # ActiveRecord Trickery
    # =====================
    #
    # Authlogic looks like ActiveRecord, sounds like ActiveRecord, but its not
    # ActiveRecord. That's the goal here. This is useful for the various rails
    # helper methods such as form_for, error_messages_for, or any method that
    # expects an ActiveRecord object. The point is to disguise the object as an
    # ActiveRecord object so we can take advantage of the many ActiveRecord
    # tools.
    #
    # Brute Force Protection
    # ======================
    #
    # A brute force attacks is executed by hammering a login with as many password
    # combinations as possible, until one works. A brute force attacked is generally
    # combated with a slow hashing algorithm such as BCrypt. You can increase the cost,
    # which makes the hash generation slower, and ultimately increases the time it takes
    # to execute a brute force attack. Just to put this into perspective, if a hacker was
    # to gain access to your server and execute a brute force attack locally, meaning
    # there is no network lag, it would probably take decades to complete. Now throw in
    # network lag and it would take MUCH longer.
    #
    # But for those that are extra paranoid and can't get enough protection, why not stop
    # them as soon as you realize something isn't right? That's what this module is all
    # about. By default the consecutive_failed_logins_limit configuration option is set to
    # 50, if someone consecutively fails to login after 50 attempts their account will be
    # suspended. This is a very liberal number and at this point it should be obvious that
    # something is not right. If you wish to lower this number just set the configuration
    # to a lower number:
    #
    #   class UserSession < Authlogic::Session::Base
    #     consecutive_failed_logins_limit 10
    #   end
    #
    # Callbacks
    # =========
    #
    # Between these callbacks and the configuration, this is the contract between me and
    # you to safely modify Authlogic's behavior. I will do everything I can to make sure
    # these do not change.
    #
    # Check out the sub modules of Authlogic::Session. They are very concise, clear, and
    # to the point. More importantly they use the same API that you would use to extend
    # Authlogic. That being said, they are great examples of how to extend Authlogic and
    # add / modify behavior to Authlogic. These modules could easily be pulled out into
    # their own plugin and become an "add on" without any change.
    #
    # Now to the point of this module. Just like in ActiveRecord you have before_save,
    # before_validation, etc. You have similar callbacks with Authlogic, see the METHODS
    # constant below. The order of execution is as follows:
    #
    #   before_persisting
    #   persist
    #   after_persisting
    #   [save record if record.has_changes_to_save?]
    #
    #   before_validation
    #   before_validation_on_create
    #   before_validation_on_update
    #   validate
    #   after_validation_on_update
    #   after_validation_on_create
    #   after_validation
    #   [save record if record.has_changes_to_save?]
    #
    #   before_save
    #   before_create
    #   before_update
    #   after_update
    #   after_create
    #   after_save
    #   [save record if record.has_changes_to_save?]
    #
    #   before_destroy
    #   [save record if record.has_changes_to_save?]
    #   after_destroy
    #
    # Notice the "save record if has_changes_to_save" lines above. This helps with performance. If
    # you need to make changes to the associated record, there is no need to save the
    # record, Authlogic will do it for you. This allows multiple modules to modify the
    # record and execute as few queries as possible.
    #
    # **WARNING**: unlike ActiveRecord, these callbacks must be set up on the class level:
    #
    #   class UserSession < Authlogic::Session::Base
    #     before_validation :my_method
    #     validate :another_method
    #     # ..etc
    #   end
    #
    # You can NOT define a "before_validation" method, this is bad practice and does not
    # allow Authlogic to extend properly with multiple extensions. Please ONLY use the
    # method above.
    #
    # HTTP Basic Authentication
    # =========================
    #
    # Handles all authentication that deals with basic HTTP auth. Which is
    # authentication built into the HTTP protocol:
    #
    #   http://username:password@whatever.com
    #
    # Also, if you are not comfortable letting users pass their raw username and
    # password you can use a single access token, as described below.
    #
    # Magic Columns
    # =============
    #
    # Just like ActiveRecord has "magic" columns, such as: created_at and updated_at.
    # Authlogic has its own "magic" columns too:
    #
    # * login_count - Increased every time an explicit login is made. This will *NOT*
    #   increase if logging in by a session, cookie, or basic http auth
    # * failed_login_count - This increases for each consecutive failed login. See
    #   the consecutive_failed_logins_limit option for details.
    # * last_request_at - Updates every time the user logs in, either by explicitly
    #   logging in, or logging in by cookie, session, or http auth
    # * current_login_at - Updates with the current time when an explicit login is made.
    # * last_login_at - Updates with the value of current_login_at before it is reset.
    # * current_login_ip - Updates with the request ip when an explicit login is made.
    # * last_login_ip - Updates with the value of current_login_ip before it is reset.
    #
    # Multiple Simultaneous Sessions
    # ==============================
    #
    # See `id`. Allows you to separate sessions with an id, ultimately letting
    # you create multiple sessions for the same user.
    #
    # Timeout
    # =======
    #
    # Think about financial websites, if you are inactive for a certain period
    # of time you will be asked to log back in on your next request. You can do
    # this with Authlogic easily, there are 2 parts to this:
    #
    # 1. Define the timeout threshold:
    #
    #   acts_as_authentic do |c|
    #     c.logged_in_timeout = 10.minutes # default is 10.minutes
    #   end
    #
    # 2. Enable logging out on timeouts
    #
    #   class UserSession < Authlogic::Session::Base
    #     logout_on_timeout true # default is false
    #   end
    #
    # This will require a user to log back in if they are inactive for more than
    # 10 minutes. In order for this feature to be used you must have a
    # last_request_at datetime column in your table for whatever model you are
    # authenticating with.
    #
    # Params
    # ======
    #
    # This module is responsible for authenticating the user via params, which ultimately
    # allows the user to log in using a URL like the following:
    #
    #   https://www.domain.com?user_credentials=4LiXF7FiGUppIPubBPey
    #
    # Notice the token in the URL, this is a single access token. A single access token is
    # used for single access only, it is not persisted. Meaning the user provides it,
    # Authlogic grants them access, and that's it. If they want access again they need to
    # provide the token again. Authlogic will *NEVER* try to persist the session after
    # authenticating through this method.
    #
    # For added security, this token is *ONLY* allowed for RSS and ATOM requests. You can
    # change this with the configuration. You can also define if it is allowed dynamically
    # by defining a single_access_allowed? method in your controller. For example:
    #
    #   class UsersController < ApplicationController
    #     private
    #       def single_access_allowed?
    #         action_name == "index"
    #       end
    #
    # Also, by default, this token is permanent. Meaning if the user changes their
    # password, this token will remain the same. It will only change when it is explicitly
    # reset.
    #
    # You can modify all of this behavior with the Config sub module.
    #
    # Perishable Token
    # ================
    #
    # Maintains the perishable token, which is helpful for confirming records or
    # authorizing records to reset their password. All that this module does is
    # reset it after a session have been saved, just keep it changing. The more
    # it changes, the tighter the security.
    #
    # See Authlogic::ActsAsAuthentic::PerishableToken for more information.
    #
    # Scopes
    # ======
    #
    # Authentication can be scoped, and it's easy, you just need to define how you want to
    # scope everything. See `.with_scope`.
    #
    # Unauthorized Record
    # ===================
    #
    # Allows you to create session with an object. Ex:
    #
    #   UserSession.create(my_user_object)
    #
    # Be careful with this, because Authlogic is assuming that you have already
    # confirmed that the user is who he says he is.
    #
    # For example, this is the method used to persist the session internally.
    # Authlogic finds the user with the persistence token. At this point we know
    # the user is who he says he is, so Authlogic just creates a session with
    # the record. This is particularly useful for 3rd party authentication
    # methods, such as OpenID. Let that method verify the identity, once it's
    # verified, pass the object and create a session.
    #
    # Magic States
    # ============
    #
    # Authlogic tries to check the state of the record before creating the session. If
    # your record responds to the following methods and any of them return false,
    # validation will fail:
    #
    #   Method name           Description
    #   active?               Is the record marked as active?
    #   approved?             Has the record been approved?
    #   confirmed?            Has the record been confirmed?
    #
    # Authlogic does nothing to define these methods for you, its up to you to define what
    # they mean. If your object responds to these methods Authlogic will use them,
    # otherwise they are ignored.
    #
    # What's neat about this is that these are checked upon any type of login. When
    # logging in explicitly, by cookie, session, or basic http auth. So if you mark a user
    # inactive in the middle of their session they wont be logged back in next time they
    # refresh the page. Giving you complete control.
    #
    # Need Authlogic to check your own "state"? No problem, check out the hooks section
    # below. Add in a before_validation to do your own checking. The sky is the limit.
    #
    # Validation
    # ==========
    #
    # The errors in Authlogic work just like ActiveRecord. In fact, it uses
    # the `ActiveModel::Errors` class. Use it the same way:
    #
    # ```
    # class UserSession
    #   validate :check_if_awesome
    #
    #   private
    #
    #   def check_if_awesome
    #     if login && !login.include?("awesome")
    #       errors.add(:login, "must contain awesome")
    #     end
    #     unless attempted_record.awesome?
    #       errors.add(:base, "You must be awesome to log in")
    #     end
    #   end
    # end
    # ```
    class Base
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      extend Authlogic::Config
      include ActiveSupport::Callbacks

      E_AC_PARAMETERS = <<~EOS
        Passing an ActionController::Parameters to Authlogic is not allowed.

        In Authlogic 3, especially during the transition of rails to Strong
        Parameters, it was common for Authlogic users to forget to `permit`
        their params. They would pass their params into Authlogic, we'd call
        `to_h`, and they'd be surprised when authentication failed.

        In 2018, people are still making this mistake. We'd like to help them
        and make authlogic a little simpler at the same time, so in Authlogic
        3.7.0, we deprecated the use of ActionController::Parameters. Instead,
        pass a plain Hash. Please replace:

            UserSession.new(user_session_params)
            UserSession.create(user_session_params)

        with

            UserSession.new(user_session_params.to_h)
            UserSession.create(user_session_params.to_h)

        And don't forget to `permit`!

        We discussed this issue thoroughly between late 2016 and early
        2018. Notable discussions include:

        - https://github.com/binarylogic/authlogic/issues/512
        - https://github.com/binarylogic/authlogic/pull/558
        - https://github.com/binarylogic/authlogic/pull/577
      EOS
      VALID_SAME_SITE_VALUES = [nil, "Lax", "Strict", "None"].freeze

      # Callbacks
      # =========

      METHODS = %w[
        before_persisting
        persist
        after_persisting
        before_validation
        before_validation_on_create
        before_validation_on_update
        validate
        after_validation_on_update
        after_validation_on_create
        after_validation
        before_save
        before_create
        before_update
        after_update
        after_create
        after_save
        before_destroy
        after_destroy
      ].freeze

      # Defines the "callback installation methods" used below.
      METHODS.each do |method|
        class_eval <<-EOS, __FILE__, __LINE__ + 1
            def self.#{method}(*filter_list, &block)
              set_callback(:#{method}, *filter_list, &block)
            end
        EOS
      end

      # Defines session life cycle events that support callbacks.
      define_callbacks(
        *METHODS,
        terminator: ->(_target, result_lambda) { result_lambda.call == false }
      )
      define_callbacks(
        "persist",
        terminator: ->(_target, result_lambda) { result_lambda.call == true }
      )

      # Use the "callback installation methods" defined above
      # -----------------------------------------------------

      before_persisting :reset_stale_state

      # `persist` callbacks, in order of priority
      persist :persist_by_params
      persist :persist_by_cookie
      persist :persist_by_session
      persist :persist_by_http_auth, if: :persist_by_http_auth?

      after_persisting :enforce_timeout
      after_persisting :update_session, unless: :single_access?
      after_persisting :set_last_request_at

      before_save :update_info
      before_save :set_last_request_at

      after_save :reset_perishable_token!
      after_save :save_cookie
      after_save :update_session

      after_destroy :destroy_cookie
      after_destroy :update_session

      # `validate` callbacks, in deliberate order. For example,
      # validate_magic_states must run *after* a record is found.
      validate :validate_by_password, if: :authenticating_with_password?
      validate(
        :validate_by_unauthorized_record,
        if: :authenticating_with_unauthorized_record?
      )
      validate :validate_magic_states, unless: :disable_magic_states?
      validate :reset_failed_login_count, if: :reset_failed_login_count?
      validate :validate_failed_logins, if: :being_brute_force_protected?
      validate :increase_failed_login_count

      # Accessors
      # =========

      class << self
        attr_accessor(
          :configured_password_methods
        )
      end
      attr_accessor(
        :invalid_password,
        :new_session,
        :priority_record,
        :record,
        :single_access,
        :stale_record,
        :unauthorized_record
      )
      attr_writer(
        :scope,
        :id
      )

      # Public class methods
      # ====================

      class << self
        # Returns true if a controller has been set and can be used properly.
        # This MUST be set before anything can be done. Similar to how
        # ActiveRecord won't allow you to do anything without establishing a DB
        # connection. In your framework environment this is done for you, but if
        # you are using Authlogic outside of your framework, you need to assign
        # a controller object to Authlogic via
        # Authlogic::Session::Base.controller = obj. See the controller= method
        # for more information.
        def activated?
          !controller.nil?
        end

        # Allow users to log in via HTTP basic authentication.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def allow_http_basic_auth(value = nil)
          rw_config(:allow_http_basic_auth, value, false)
        end
        alias allow_http_basic_auth= allow_http_basic_auth

        # Lets you change which model to use for authentication.
        #
        # * <tt>Default:</tt> inferred from the class name. UserSession would
        #   automatically try User
        # * <tt>Accepts:</tt> an ActiveRecord class
        def authenticate_with(klass)
          @klass_name = klass.name
          @klass = klass
        end
        alias authenticate_with= authenticate_with

        # The current controller object
        def controller
          RequestStore.store[:authlogic_controller]
        end

        # This accepts a controller object wrapped with the Authlogic controller
        # adapter. The controller adapters close the gap between the different
        # controllers in each framework. That being said, Authlogic is expecting
        # your object's class to extend
        # Authlogic::ControllerAdapters::AbstractAdapter. See
        # Authlogic::ControllerAdapters for more info.
        #
        # Lastly, this is thread safe.
        def controller=(value)
          RequestStore.store[:authlogic_controller] = value
        end

        # To help protect from brute force attacks you can set a limit on the
        # allowed number of consecutive failed logins. By default this is 50,
        # this is a very liberal number, and if someone fails to login after 50
        # tries it should be pretty obvious that it's a machine trying to login
        # in and very likely a brute force attack.
        #
        # In order to enable this field your model MUST have a
        # failed_login_count (integer) field.
        #
        # If you don't know what a brute force attack is, it's when a machine
        # tries to login into a system using every combination of character
        # possible. Thus resulting in possibly millions of attempts to log into
        # an account.
        #
        # * <tt>Default:</tt> 50
        # * <tt>Accepts:</tt> Integer, set to 0 to disable
        def consecutive_failed_logins_limit(value = nil)
          rw_config(:consecutive_failed_logins_limit, value, 50)
        end
        alias consecutive_failed_logins_limit= consecutive_failed_logins_limit

        # The name of the cookie or the key in the cookies hash. Be sure and use
        # a unique name. If you have multiple sessions and they use the same
        # cookie it will cause problems. Also, if a id is set it will be
        # inserted into the beginning of the string. Example:
        #
        #   session = UserSession.new
        #   session.cookie_key => "user_credentials"
        #
        #   session = UserSession.new(:super_high_secret)
        #   session.cookie_key => "super_high_secret_user_credentials"
        #
        # * <tt>Default:</tt> "#{klass_name.underscore}_credentials"
        # * <tt>Accepts:</tt> String
        def cookie_key(value = nil)
          rw_config(:cookie_key, value, "#{klass_name.underscore}_credentials")
        end
        alias cookie_key= cookie_key

        # A convenience method. The same as:
        #
        #   session = UserSession.new(*args)
        #   session.save
        #
        # Instead you can do:
        #
        #   UserSession.create(*args)
        def create(*args, &block)
          session = new(*args)
          session.save(&block)
          session
        end

        # Same as create but calls create!, which raises an exception when
        # validation fails.
        def create!(*args)
          session = new(*args)
          session.save!
          session
        end

        # Set this to true if you want to disable the checking of active?, approved?, and
        # confirmed? on your record. This is more or less of a convenience feature, since
        # 99% of the time if those methods exist and return false you will not want the
        # user logging in. You could easily accomplish this same thing with a
        # before_validation method or other callbacks.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def disable_magic_states(value = nil)
          rw_config(:disable_magic_states, value, false)
        end
        alias disable_magic_states= disable_magic_states

        # Once the failed logins limit has been exceed, how long do you want to
        # ban the user? This can be a temporary or permanent ban.
        #
        # * <tt>Default:</tt> 2.hours
        # * <tt>Accepts:</tt> Fixnum, set to 0 for permanent ban
        def failed_login_ban_for(value = nil)
          rw_config(:failed_login_ban_for, (!value.nil? && value) || value, 2.hours.to_i)
        end
        alias failed_login_ban_for= failed_login_ban_for

        # This is how you persist a session. This finds the record for the
        # current session using a variety of methods. It basically tries to "log
        # in" the user without the user having to explicitly log in. Check out
        # the other Authlogic::Session modules for more information.
        #
        # The best way to use this method is something like:
        #
        #   helper_method :current_user_session, :current_user
        #
        #   def current_user_session
        #     return @current_user_session if defined?(@current_user_session)
        #     @current_user_session = UserSession.find
        #   end
        #
        #   def current_user
        #     return @current_user if defined?(@current_user)
        #     @current_user = current_user_session && current_user_session.user
        #   end
        #
        # Also, this method accepts a single parameter as the id, to find
        # session that you marked with an id:
        #
        #   UserSession.find(:secure)
        #
        # See the id method for more information on ids.
        #
        # Priority Record
        # ===============
        #
        # This internal feature supports ActiveRecord's optimistic locking feature,
        # which is automatically enabled when a table has a `lock_version` column.
        #
        # ```
        # # https://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html
        # p1 = Person.find(1)
        # p2 = Person.find(1)
        # p1.first_name = "Michael"
        # p1.save
        # p2.first_name = "should fail"
        # p2.save # Raises an ActiveRecord::StaleObjectError
        # ```
        #
        # Now, consider the following Authlogic scenario:
        #
        # ```
        # User.log_in_after_password_change = true
        # ben = User.find(1)
        # UserSession.create(ben)
        # ben.password = "newpasswd"
        # ben.password_confirmation = "newpasswd"
        # ben.save
        # ```
        #
        # We've used one of Authlogic's session maintenance features,
        # `log_in_after_password_change`. So, when we call `ben.save`, there is a
        # `before_save` callback that logs Ben in (`UserSession.find`). Well, when
        # we log Ben in, we update his user record, eg. `login_count`. When we're
        # done logging Ben in, then the normal `ben.save` happens. So, there were
        # two `update` queries. If those two updates came from different User
        # instances, we would get a `StaleObjectError`.
        #
        # Our solution is to carefully pass around a single `User` instance, using
        # it for all `update` queries, thus avoiding the `StaleObjectError`.
        def find(id = nil, priority_record = nil)
          session = new({ priority_record: priority_record }, id)
          session.priority_record = priority_record
          if session.persisting?
            session
          end
        end

        # Authlogic tries to validate the credentials passed to it. One part of
        # validation is actually finding the user and making sure it exists.
        # What method it uses the do this is up to you.
        #
        # Let's say you have a UserSession that is authenticating a User. By
        # default UserSession will call User.find_by_login(login). You can
        # change what method UserSession calls by specifying it here. Then in
        # your User model you can make that method do anything you want, giving
        # you complete control of how users are found by the UserSession.
        #
        # Let's take an example: You want to allow users to login by username or
        # email. Set this to the name of the class method that does this in the
        # User model. Let's call it "find_by_username_or_email"
        #
        #   class User < ActiveRecord::Base
        #     def self.find_by_username_or_email(login)
        #       find_by_username(login) || find_by_email(login)
        #     end
        #   end
        #
        # Now just specify the name of this method for this configuration option
        # and you are all set. You can do anything you want here. Maybe you
        # allow users to have multiple logins and you want to search a has_many
        # relationship, etc. The sky is the limit.
        #
        # * <tt>Default:</tt> "find_by_smart_case_login_field"
        # * <tt>Accepts:</tt> Symbol or String
        def find_by_login_method(value = nil)
          rw_config(:find_by_login_method, value, "find_by_smart_case_login_field")
        end
        alias find_by_login_method= find_by_login_method

        # The text used to identify credentials (username/password) combination
        # when a bad login attempt occurs. When you show error messages for a
        # bad login, it's considered good security practice to hide which field
        # the user has entered incorrectly (the login field or the password
        # field). For a full explanation, see
        # http://www.gnucitizen.org/blog/username-enumeration-vulnerabilities/
        #
        # Example of use:
        #
        #   class UserSession < Authlogic::Session::Base
        #     generalize_credentials_error_messages true
        #   end
        #
        #   This would make the error message for bad logins and bad passwords
        #   look identical:
        #
        #   Login/Password combination is not valid
        #
        #   Alternatively you may use a custom message:
        #
        #   class UserSession < AuthLogic::Session::Base
        #     generalize_credentials_error_messages "Your login information is invalid"
        #   end
        #
        #   This will instead show your custom error message when the UserSession is invalid.
        #
        # The downside to enabling this is that is can be too vague for a user
        # that has a hard time remembering their username and password
        # combinations. It also disables the ability to to highlight the field
        # with the error when you use form_for.
        #
        # If you are developing an app where security is an extreme priority
        # (such as a financial application), then you should enable this.
        # Otherwise, leaving this off is fine.
        #
        # * <tt>Default</tt> false
        # * <tt>Accepts:</tt> Boolean
        def generalize_credentials_error_messages(value = nil)
          rw_config(:generalize_credentials_error_messages, value, false)
        end
        alias generalize_credentials_error_messages= generalize_credentials_error_messages

        # HTTP authentication realm
        #
        # Sets the HTTP authentication realm.
        #
        # Note: This option has no effect unless request_http_basic_auth is true
        #
        # * <tt>Default:</tt> 'Application'
        # * <tt>Accepts:</tt> String
        def http_basic_auth_realm(value = nil)
          rw_config(:http_basic_auth_realm, value, "Application")
        end
        alias http_basic_auth_realm= http_basic_auth_realm

        # Should the cookie be set as httponly?  If true, the cookie will not be
        # accessible from javascript
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def httponly(value = nil)
          rw_config(:httponly, value, true)
        end
        alias httponly= httponly

        # How to name the class, works JUST LIKE ActiveRecord, except it uses
        # the following namespace:
        #
        #   authlogic.models.user_session
        def human_name(*)
          I18n.t("models.#{name.underscore}", count: 1, default: name.humanize)
        end

        def i18n_scope
          I18n.scope
        end

        # The name of the class that this session is authenticating with. For
        # example, the UserSession class will authenticate with the User class
        # unless you specify otherwise in your configuration. See
        # authenticate_with for information on how to change this value.
        def klass
          @klass ||= klass_name ? klass_name.constantize : nil
        end

        # The string of the model name class guessed from the actual session class name.
        def klass_name
          return @klass_name if defined?(@klass_name)
          @klass_name = name.scan(/(.*)Session/)[0]
          @klass_name = klass_name ? klass_name[0] : nil
        end

        # The name of the method you want Authlogic to create for storing the
        # login / username. Keep in mind this is just for your
        # Authlogic::Session, if you want it can be something completely
        # different than the field in your model. So if you wanted people to
        # login with a field called "login" and then find users by email this is
        # completely doable. See the find_by_login_method configuration option
        # for more details.
        #
        # * <tt>Default:</tt> klass.login_field || klass.email_field
        # * <tt>Accepts:</tt> Symbol or String
        def login_field(value = nil)
          rw_config(:login_field, value, klass.login_field || klass.email_field)
        end
        alias login_field= login_field

        # With acts_as_authentic you get a :logged_in_timeout configuration
        # option. If this is set, after this amount of time has passed the user
        # will be marked as logged out. Obviously, since web based apps are on a
        # per request basis, we have to define a time limit threshold that
        # determines when we consider a user to be "logged out". Meaning, if
        # they login and then leave the website, when do mark them as logged
        # out? I recommend just using this as a fun feature on your website or
        # reports, giving you a ballpark number of users logged in and active.
        # This is not meant to be a dead accurate representation of a user's
        # logged in state, since there is really no real way to do this with web
        # based apps. Think about a user that logs in and doesn't log out. There
        # is no action that tells you that the user isn't technically still
        # logged in and active.
        #
        # That being said, you can use that feature to require a new login if
        # their session times out. Similar to how financial sites work. Just set
        # this option to true and if your record returns true for stale? then
        # they will be required to log back in.
        #
        # Lastly, UserSession.find will still return an object if the session is
        # stale, but you will not get a record. This allows you to determine if
        # the user needs to log back in because their session went stale, or
        # because they just aren't logged in. Just call
        # current_user_session.stale? as your flag.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def logout_on_timeout(value = nil)
          rw_config(:logout_on_timeout, value, false)
        end
        alias logout_on_timeout= logout_on_timeout

        # Every time a session is found the last_request_at field for that record is
        # updated with the current time, if that field exists. If you want to limit how
        # frequent that field is updated specify the threshold here. For example, if your
        # user is making a request every 5 seconds, and you feel this is too frequent, and
        # feel a minute is a good threshold. Set this to 1.minute. Once a minute has
        # passed in between requests the field will be updated.
        #
        # * <tt>Default:</tt> 0
        # * <tt>Accepts:</tt> integer representing time in seconds
        def last_request_at_threshold(value = nil)
          rw_config(:last_request_at_threshold, value, 0)
        end
        alias last_request_at_threshold= last_request_at_threshold

        # Works exactly like cookie_key, but for params. So a user can login via
        # params just like a cookie or a session. Your URL would look like:
        #
        #   http://www.domain.com?user_credentials=my_single_access_key
        #
        # You can change the "user_credentials" key above with this
        # configuration option. Keep in mind, just like cookie_key, if you
        # supply an id the id will be appended to the front. Check out
        # cookie_key for more details. Also checkout the "Single Access /
        # Private Feeds Access" section in the README.
        #
        # * <tt>Default:</tt> cookie_key
        # * <tt>Accepts:</tt> String
        def params_key(value = nil)
          rw_config(:params_key, value, cookie_key)
        end
        alias params_key= params_key

        # Works exactly like login_field, but for the password instead. Returns
        # :password if a login_field exists.
        #
        # * <tt>Default:</tt> :password
        # * <tt>Accepts:</tt> Symbol or String
        def password_field(value = nil)
          rw_config(:password_field, value, login_field && :password)
        end
        alias password_field= password_field

        # Whether or not to request HTTP authentication
        #
        # If set to true and no HTTP authentication credentials are sent with
        # the request, the Rails controller method
        # authenticate_or_request_with_http_basic will be used and a '401
        # Authorization Required' header will be sent with the response.  In
        # most cases, this will cause the classic HTTP authentication popup to
        # appear in the users browser.
        #
        # If set to false, the Rails controller method
        # authenticate_with_http_basic is used and no 401 header is sent.
        #
        # Note: This parameter has no effect unless allow_http_basic_auth is
        # true
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def request_http_basic_auth(value = nil)
          rw_config(:request_http_basic_auth, value, false)
        end
        alias request_http_basic_auth= request_http_basic_auth

        # If sessions should be remembered by default or not.
        #
        # * <tt>Default:</tt> false
        # * <tt>Accepts:</tt> Boolean
        def remember_me(value = nil)
          rw_config(:remember_me, value, false)
        end
        alias remember_me= remember_me

        # The length of time until the cookie expires.
        #
        # * <tt>Default:</tt> 3.months
        # * <tt>Accepts:</tt> Integer, length of time in seconds, such as 60 or 3.months
        def remember_me_for(value = nil)
          rw_config(:remember_me_for, value, 3.months)
        end
        alias remember_me_for= remember_me_for

        # Should the cookie be prevented from being send along with cross-site
        # requests?
        #
        # * <tt>Default:</tt> nil
        # * <tt>Accepts:</tt> String, one of nil, 'Lax' or 'Strict'
        def same_site(value = nil)
          unless VALID_SAME_SITE_VALUES.include?(value)
            msg = "Invalid same_site value: #{value}. Valid: #{VALID_SAME_SITE_VALUES.inspect}"
            raise ArgumentError, msg
          end
          rw_config(:same_site, value)
        end
        alias same_site= same_site

        # The current scope set, should be used in the block passed to with_scope.
        def scope
          RequestStore.store[:authlogic_scope]
        end

        # Should the cookie be set as secure?  If true, the cookie will only be sent over
        # SSL connections
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def secure(value = nil)
          rw_config(:secure, value, true)
        end
        alias secure= secure

        # Should the cookie be signed? If the controller adapter supports it, this is a
        # measure against cookie tampering.
        def sign_cookie(value = nil)
          if value && !controller.cookies.respond_to?(:signed)
            raise "Signed cookies not supported with #{controller.class}!"
          end
          rw_config(:sign_cookie, value, false)
        end
        alias sign_cookie= sign_cookie

        # Should the cookie be encrypted? If the controller adapter supports it, this is a
        # measure to hide the contents of the cookie (e.g. persistence_token)
        def encrypt_cookie(value = nil)
          if value && !controller.cookies.respond_to?(:encrypted)
            raise "Encrypted cookies not supported with #{controller.class}!"
          end
          if value && sign_cookie
            raise "It is recommended to use encrypt_cookie instead of sign_cookie. " \
                  "You may not enable both options."
          end
          rw_config(:encrypt_cookie, value, false)
        end
        alias_method :encrypt_cookie=, :encrypt_cookie

        # Works exactly like cookie_key, but for sessions. See cookie_key for more info.
        #
        # * <tt>Default:</tt> cookie_key
        # * <tt>Accepts:</tt> Symbol or String
        def session_key(value = nil)
          rw_config(:session_key, value, cookie_key)
        end
        alias session_key= session_key

        # Authentication is allowed via a single access token, but maybe this is
        # something you don't want for your application as a whole. Maybe this
        # is something you only want for specific request types. Specify a list
        # of allowed request types and single access authentication will only be
        # allowed for the ones you specify.
        #
        # * <tt>Default:</tt> ["application/rss+xml", "application/atom+xml"]
        # * <tt>Accepts:</tt> String of a request type, or :all or :any to
        #   allow single access authentication for any and all request types
        def single_access_allowed_request_types(value = nil)
          rw_config(
            :single_access_allowed_request_types,
            value,
            ["application/rss+xml", "application/atom+xml"]
          )
        end
        alias single_access_allowed_request_types= single_access_allowed_request_types

        # The name of the method in your model used to verify the password. This
        # should be an instance method. It should also be prepared to accept a
        # raw password and a crytped password.
        #
        # * <tt>Default:</tt> "valid_password?" defined in acts_as_authentic/password.rb
        # * <tt>Accepts:</tt> Symbol or String
        def verify_password_method(value = nil)
          rw_config(:verify_password_method, value, "valid_password?")
        end
        alias verify_password_method= verify_password_method

        # What with_scopes focuses on is scoping the query when finding the
        # object and the name of the cookie / session. It works very similar to
        # ActiveRecord::Base#with_scopes. It accepts a hash with any of the
        # following options:
        #
        # * <tt>find_options:</tt> any options you can pass into ActiveRecord::Base.find.
        #   This is used when trying to find the record.
        # * <tt>id:</tt> The id of the session, this gets merged with the real id. For
        #   information ids see the id method.
        #
        # Here is how you use it:
        #
        # ```
        # UserSession.with_scope(find_options: User.where(account_id: 2), id: "account_2") do
        #   UserSession.find
        # end
        # ```
        #
        # Essentially what the above does is scope the searching of the object
        # with the sql you provided. So instead of:
        #
        # ```
        # User.where("login = 'ben'").first
        # ```
        #
        # it would effectively be:
        #
        # ```
        # User.where("login = 'ben' and account_id = 2").first
        # ```
        #
        # You will also notice the :id option. This works just like the id
        # method. It scopes your cookies. So the name of your cookie will be:
        #
        #   account_2_user_credentials
        #
        # instead of:
        #
        #   user_credentials
        #
        # What is also nifty about scoping with an :id is that it merges your
        # id's. So if you do:
        #
        #   UserSession.with_scope(
        #     find_options: { conditions: "account_id = 2"},
        #     id: "account_2"
        #   ) do
        #     session = UserSession.new
        #     session.id = :secure
        #   end
        #
        # The name of your cookies will be:
        #
        #   secure_account_2_user_credentials
        def with_scope(options = {})
          raise ArgumentError, "You must provide a block" unless block_given?
          self.scope = options
          result = yield
          self.scope = nil
          result
        end
      end

      # Constructor
      # ===========

      def initialize(*args)
        @id = nil
        self.scope = self.class.scope
        define_record_alias_method
        raise Activation::NotActivatedError unless self.class.activated?
        unless self.class.configured_password_methods
          configure_password_methods
          self.class.configured_password_methods = true
        end
        instance_variable_set("@#{password_field}", nil)
        self.credentials = args
      end

      # Public instance methods
      # =======================

      # You should use this as a place holder for any records that you find
      # during validation. The main reason for this is to allow other modules to
      # use it if needed. Take the failed_login_count feature, it needs this in
      # order to increase the failed login count.
      def attempted_record
        @attempted_record
      end

      # See attempted_record
      def attempted_record=(value)
        value = priority_record if value == priority_record # See notes in `.find`
        @attempted_record = value
      end

      # Returns true when the consecutive_failed_logins_limit has been
      # exceeded and is being temporarily banned. Notice the word temporary,
      # the user will not be permanently banned unless you choose to do so
      # with configuration. By default they will be banned for 2 hours. During
      # that 2 hour period this method will return true.
      def being_brute_force_protected?
        exceeded_failed_logins_limit? &&
          (
            failed_login_ban_for <= 0 ||
              attempted_record.respond_to?(:updated_at) &&
              attempted_record.updated_at >= failed_login_ban_for.seconds.ago
          )
      end

      # The credentials you passed to create your session, in a redacted format
      # intended for output (debugging, logging). See credentials= for more
      # info.
      #
      # @api private
      def credentials
        if authenticating_with_unauthorized_record?
          { unauthorized_record: "<protected>" }
        elsif authenticating_with_password?
          {
            login_field.to_sym => send(login_field),
            password_field.to_sym => "<protected>"
          }
        else
          {}
        end
      end

      # Set your credentials before you save your session. There are many
      # method signatures.
      #
      # ```
      # # A hash of credentials is most common
      # session.credentials = { login: "foo", password: "bar", remember_me: true }
      #
      # # You must pass an actual Hash, `ActionController::Parameters` is
      # # specifically not allowed.
      #
      # # You can pass an array of objects:
      # session.credentials = [my_user_object, true]
      #
      # # If you need to set an id (see `#id`) pass it last.
      # session.credentials = [
      #   {:login => "foo", :password => "bar", :remember_me => true},
      #   :my_id
      # ]
      # session.credentials = [my_user_object, true, :my_id]
      #
      # The `id` is something that you control yourself, it should never be
      # set from a hash or a form.
      #
      # # Finally, there's priority_record
      # [{ priority_record: my_object }, :my_id]
      # ```
      #
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def credentials=(value)
        normalized = Array.wrap(value)
        if normalized.first.class.name == "ActionController::Parameters"
          raise TypeError, E_AC_PARAMETERS
        end

        # Allows you to set the remember_me option when passing credentials.
        values = value.is_a?(Array) ? value : [value]
        case values.first
        when Hash
          if values.first.with_indifferent_access.key?(:remember_me)
            self.remember_me = values.first.with_indifferent_access[:remember_me]
          end
        else
          r = values.find { |val| val.is_a?(TrueClass) || val.is_a?(FalseClass) }
          self.remember_me = r unless r.nil?
        end

        # Accepts the login_field / password_field credentials combination in
        # hash form.
        #
        # You must pass an actual Hash, `ActionController::Parameters` is
        # specifically not allowed.
        values = Array.wrap(value)
        if values.first.is_a?(Hash)
          sliced = values
            .first
            .with_indifferent_access
            .slice(login_field, password_field)
          sliced.each do |field, val|
            next if val.blank?
            send("#{field}=", val)
          end
        end

        # Setting the unauthorized record if it exists in the credentials passed.
        values = value.is_a?(Array) ? value : [value]
        self.unauthorized_record = values.first if values.first.class < ::ActiveRecord::Base

        # Setting the id if it is passed in the credentials.
        values = value.is_a?(Array) ? value : [value]
        self.id = values.last if values.last.is_a?(Symbol)

        # Setting priority record if it is passed. The only way it can be passed
        # is through an array:
        #
        #   session.credentials = [real_user_object, priority_user_object]
        #
        # See notes in `.find`
        values = value.is_a?(Array) ? value : [value]
        self.priority_record = values[1] if values[1].class < ::ActiveRecord::Base
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Clears all errors and the associated record, you should call this
      # terminate a session, thus requiring the user to authenticate again if
      # it is needed.
      def destroy
        run_callbacks :before_destroy
        save_record
        errors.clear
        @record = nil
        run_callbacks :after_destroy
        true
      end

      def destroyed?
        record.nil?
      end

      # @api public
      def errors
        @errors ||= ::ActiveModel::Errors.new(self)
      end

      # If the cookie should be marked as httponly (not accessible via javascript)
      def httponly
        return @httponly if defined?(@httponly)
        @httponly = self.class.httponly
      end

      # Accepts a boolean as to whether the cookie should be marked as
      # httponly.  If true, the cookie will not be accessible from javascript
      def httponly=(value)
        @httponly = value
      end

      # See httponly
      def httponly?
        httponly == true || httponly == "true" || httponly == "1"
      end

      # Allows you to set a unique identifier for your session, so that you can
      # have more than 1 session at a time.
      #
      # For example, you may want to have simultaneous private and public
      # sessions. Or, a normal user session and a "secure" user session. The
      # secure user session would be created only when they want to modify their
      # billing information, or other sensitive information.
      #
      # You can set the id during initialization (see initialize for more
      # information), or as an attribute:
      #
      #   session.id = :my_id
      #
      # Set your id before you save your session.
      #
      # Lastly, to retrieve your session with the id, use the `.find` method.
      def id
        @id
      end

      def inspect
        format(
          "#<%s: %s>",
          self.class.name,
          credentials.blank? ? "no credentials provided" : credentials.inspect
        )
      end

      def invalid_password?
        invalid_password == true
      end

      # Don't use this yourself, this is to just trick some of the helpers
      # since this is the method it calls.
      def new_record?
        new_session?
      end

      # Returns true if the session is new, meaning no action has been taken
      # on it and a successful save has not taken place.
      def new_session?
        new_session != false
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      # Returns boolean indicating if the session is being persisted or not,
      # meaning the user does not have to explicitly log in in order to be
      # logged in.
      #
      # If the session has no associated record, it will try to find a record
      # and persist the session.
      #
      # This is the method that the class level method find uses to ultimately
      # persist the session.
      def persisting?
        return true unless record.nil?
        self.attempted_record = nil
        self.remember_me = cookie_credentials&.remember_me?
        run_callbacks :before_persisting
        run_callbacks :persist
        ensure_authentication_attempted
        if errors.empty? && !attempted_record.nil?
          self.record = attempted_record
          run_callbacks :after_persisting
          save_record
          self.new_session = false
          true
        else
          false
        end
      end

      def save_record(alternate_record = nil)
        r = alternate_record || record
        if r != priority_record
          if r&.has_changes_to_save? && !r.readonly?
            r.save_without_session_maintenance(validate: false)
          end
        end
      end

      # Tells you if the record is stale or not. Meaning the record has timed
      # out. This will only return true if you set logout_on_timeout to true
      # in your configuration. Basically how a bank website works. If you
      # aren't active over a certain period of time your session becomes stale
      # and requires you to log back in.
      def stale?
        if remember_me?
          remember_me_expired?
        else
          !stale_record.nil? || (logout_on_timeout? && record && record.logged_out?)
        end
      end

      # Is the cookie going to expire after the session is over, or will it stick around?
      def remember_me
        return @remember_me if defined?(@remember_me)
        @remember_me = self.class.remember_me
      end

      # Accepts a boolean as a flag to remember the session or not. Basically
      # to expire the cookie at the end of the session or keep it for
      # "remember_me_until".
      def remember_me=(value)
        @remember_me = value
      end

      # See remember_me
      def remember_me?
        remember_me == true || remember_me == "true" || remember_me == "1"
      end

      # Has the cookie expired due to current time being greater than remember_me_until.
      def remember_me_expired?
        return unless remember_me?
        cookie_credentials.remember_me_until < ::Time.now
      end

      # How long to remember the user if remember_me is true. This is based on the class
      # level configuration: remember_me_for
      def remember_me_for
        return unless remember_me?
        self.class.remember_me_for
      end

      # When to expire the cookie. See remember_me_for configuration option to change
      # this.
      def remember_me_until
        return unless remember_me?
        remember_me_for.from_now
      end

      # After you have specified all of the details for your session you can
      # try to save it. This will run validation checks and find the
      # associated record, if all validation passes. If validation does not
      # pass, the save will fail and the errors will be stored in the errors
      # object.
      def save
        result = nil
        if valid?
          self.record = attempted_record

          run_callbacks :before_save
          run_callbacks(new_session? ? :before_create : :before_update)
          run_callbacks(new_session? ? :after_create : :after_update)
          run_callbacks :after_save

          save_record
          self.new_session = false
          result = true
        else
          result = false
        end

        yield result if block_given?
        result
      end

      # Same as save but raises an exception of validation errors when
      # validation fails
      def save!
        result = save
        raise Existence::SessionInvalidError, self unless result
        result
      end

      # If the cookie should be marked as secure (SSL only)
      def secure
        return @secure if defined?(@secure)
        @secure = self.class.secure
      end

      # Accepts a boolean as to whether the cookie should be marked as secure.  If true
      # the cookie will only ever be sent over an SSL connection.
      def secure=(value)
        @secure = value
      end

      # See secure
      def secure?
        secure == true || secure == "true" || secure == "1"
      end

      # If the cookie should be marked as SameSite with 'Lax' or 'Strict' flag.
      def same_site
        return @same_site if defined?(@same_site)
        @same_site = self.class.same_site(nil)
      end

      # Accepts nil, 'Lax' or 'Strict' as possible flags.
      def same_site=(value)
        unless VALID_SAME_SITE_VALUES.include?(value)
          msg = "Invalid same_site value: #{value}. Valid: #{VALID_SAME_SITE_VALUES.inspect}"
          raise ArgumentError, msg
        end
        @same_site = value
      end

      # If the cookie should be signed
      def sign_cookie
        return @sign_cookie if defined?(@sign_cookie)
        @sign_cookie = self.class.sign_cookie
      end

      # Accepts a boolean as to whether the cookie should be signed.  If true
      # the cookie will be saved and verified using a signature.
      def sign_cookie=(value)
        @sign_cookie = value
      end

      # See sign_cookie
      def sign_cookie?
        sign_cookie == true || sign_cookie == "true" || sign_cookie == "1"
      end

      # If the cookie should be encrypted
      def encrypt_cookie
        return @encrypt_cookie if defined?(@encrypt_cookie)
        @encrypt_cookie = self.class.encrypt_cookie
      end

      # Accepts a boolean as to whether the cookie should be encrypted.  If true
      # the cookie will be saved in an encrypted state.
      def encrypt_cookie=(value)
        @encrypt_cookie = value
      end

      # See encrypt_cookie
      def encrypt_cookie?
        encrypt_cookie == true || encrypt_cookie == "true" || encrypt_cookie == "1"
      end

      # The scope of the current object
      def scope
        @scope ||= {}
      end

      def to_key
        new_record? ? nil : record.to_key
      end

      # For rails >= 3.0
      def to_model
        self
      end

      # Determines if the information you provided for authentication is valid
      # or not. If there is a problem with the information provided errors will
      # be added to the errors object and this method will return false.
      #
      # @api public
      def valid?
        errors.clear
        self.attempted_record = nil
        run_the_before_validation_callbacks

        # Run the `validate` callbacks, eg. `validate_by_password`.
        # This is when `attempted_record` is set.
        run_callbacks(:validate)

        ensure_authentication_attempted
        if errors.empty?
          run_the_after_validation_callbacks
        end
        save_record(attempted_record)
        errors.empty?
      end

      # Private class methods
      # =====================

      class << self
        private

        def scope=(value)
          RequestStore.store[:authlogic_scope] = value
        end
      end

      # Private instance methods
      # ========================

      private

      def add_general_credentials_error
        error_message =
          if self.class.generalize_credentials_error_messages.is_a? String
            self.class.generalize_credentials_error_messages
          else
            "#{login_field.to_s.humanize}/Password combination is not valid"
          end
        errors.add(
          :base,
          I18n.t("error_messages.general_credentials_error", default: error_message)
        )
      end

      def add_invalid_password_error
        if generalize_credentials_error_messages?
          add_general_credentials_error
        else
          errors.add(
            password_field,
            I18n.t("error_messages.password_invalid", default: "is not valid")
          )
        end
      end

      def add_login_not_found_error
        if generalize_credentials_error_messages?
          add_general_credentials_error
        else
          errors.add(
            login_field,
            I18n.t("error_messages.login_not_found", default: "is not valid")
          )
        end
      end

      def allow_http_basic_auth?
        self.class.allow_http_basic_auth == true
      end

      def authenticating_with_password?
        login_field && (!send(login_field).nil? || !send("protected_#{password_field}").nil?)
      end

      def authenticating_with_unauthorized_record?
        !unauthorized_record.nil?
      end

      # Used for things like cookie_key, session_key, etc.
      # Examples:
      # - user_credentials
      # - ziggity_zack_user_credentials
      #   - ziggity_zack is an "id"
      #   - see persistence_token_test.rb
      def build_key(last_part)
        [id, scope[:id], last_part].compact.join("_")
      end

      def clear_failed_login_count
        if record.respond_to?(:failed_login_count)
          record.failed_login_count = 0
        end
      end

      def consecutive_failed_logins_limit
        self.class.consecutive_failed_logins_limit
      end

      def controller
        self.class.controller
      end

      def cookie_key
        build_key(self.class.cookie_key)
      end

      # Look in the `cookie_jar`, find the cookie that contains authlogic
      # credentials (`cookie_key`).
      #
      # @api private
      # @return ::Authlogic::CookieCredentials or if no cookie is found, nil
      def cookie_credentials
        cookie_value = cookie_jar[cookie_key]
        unless cookie_value.nil?
          ::Authlogic::CookieCredentials.parse(cookie_value)
        end
      end

      def cookie_jar
        if self.class.encrypt_cookie
          controller.cookies.encrypted
        elsif self.class.sign_cookie
          controller.cookies.signed
        else
          controller.cookies
        end
      end

      def configure_password_methods
        define_login_field_methods
        define_password_field_methods
      end

      def define_login_field_methods
        return unless login_field
        self.class.send(:attr_writer, login_field) unless respond_to?("#{login_field}=")
        self.class.send(:attr_reader, login_field) unless respond_to?(login_field)
      end

      # @api private
      def define_password_field_methods
        return unless password_field
        define_password_field_writer_method
        define_password_field_reader_methods
      end

      # The password should not be accessible publicly. This way forms using
      # form_for don't fill the password with the attempted password. To prevent
      # this we just create this method that is private.
      #
      # @api private
      def define_password_field_reader_methods
        unless respond_to?(password_field)
          # Deliberate no-op method, see rationale above.
          self.class.send(:define_method, password_field) {}
        end
        self.class.class_eval(
          <<-EOS, __FILE__, __LINE__ + 1
            private
            def protected_#{password_field}
              @#{password_field}
            end
        EOS
        )
      end

      def define_password_field_writer_method
        unless respond_to?("#{password_field}=")
          self.class.send(:attr_writer, password_field)
        end
      end

      # Creating an alias method for the "record" method based on the klass
      # name, so that we can do:
      #
      #   session.user
      #
      # instead of:
      #
      #   session.record
      #
      # @api private
      def define_record_alias_method
        noun = klass_name.demodulize.underscore.to_sym
        return if respond_to?(noun)
        self.class.send(:alias_method, noun, :record)
      end

      def destroy_cookie
        controller.cookies.delete cookie_key, domain: controller.cookie_domain
      end

      def disable_magic_states?
        self.class.disable_magic_states == true
      end

      def enforce_timeout
        if stale?
          self.stale_record = record
          self.record = nil
        end
      end

      def ensure_authentication_attempted
        if errors.empty? && attempted_record.nil?
          errors.add(
            :base,
            I18n.t(
              "error_messages.no_authentication_details",
              default: "You did not provide any details for authentication."
            )
          )
        end
      end

      def exceeded_failed_logins_limit?
        !attempted_record.nil? &&
          attempted_record.respond_to?(:failed_login_count) &&
          consecutive_failed_logins_limit > 0 &&
          attempted_record.failed_login_count &&
          attempted_record.failed_login_count >= consecutive_failed_logins_limit
      end

      def find_by_login_method
        self.class.find_by_login_method
      end

      def generalize_credentials_error_messages?
        self.class.generalize_credentials_error_messages
      end

      # @api private
      def generate_cookie_for_saving
        {
          value: generate_cookie_value.to_s,
          expires: remember_me_until,
          secure: secure,
          httponly: httponly,
          same_site: same_site,
          domain: controller.cookie_domain
        }
      end

      def generate_cookie_value
        ::Authlogic::CookieCredentials.new(
          record.persistence_token,
          record.send(record.class.primary_key),
          remember_me? ? remember_me_until : nil
        )
      end

      # Returns a Proc to be executed by
      # `ActionController::HttpAuthentication::Basic` when credentials are
      # present in the HTTP request.
      #
      # @api private
      # @return Proc
      def http_auth_login_proc
        proc do |login, password|
          if !login.blank? && !password.blank?
            send("#{login_field}=", login)
            send("#{password_field}=", password)
            valid?
          end
        end
      end

      def failed_login_ban_for
        self.class.failed_login_ban_for
      end

      def increase_failed_login_count
        if invalid_password? && attempted_record.respond_to?(:failed_login_count)
          attempted_record.failed_login_count ||= 0
          attempted_record.failed_login_count += 1
        end
      end

      def increment_login_cout
        if record.respond_to?(:login_count)
          record.login_count = (record.login_count.blank? ? 1 : record.login_count + 1)
        end
      end

      def klass
        self.class.klass
      end

      def klass_name
        self.class.klass_name
      end

      def last_request_at_threshold
        self.class.last_request_at_threshold
      end

      def login_field
        self.class.login_field
      end

      def logout_on_timeout?
        self.class.logout_on_timeout == true
      end

      def params_credentials
        controller.params[params_key]
      end

      def params_enabled?
        if !params_credentials || !klass.column_names.include?("single_access_token")
          return false
        end
        if controller.responds_to_single_access_allowed?
          return controller.single_access_allowed?
        end
        params_enabled_by_allowed_request_types?
      end

      def params_enabled_by_allowed_request_types?
        case single_access_allowed_request_types
        when Array
          single_access_allowed_request_types.include?(controller.request_content_type) ||
            single_access_allowed_request_types.include?(:all)
        else
          %i[all any].include?(single_access_allowed_request_types)
        end
      end

      def params_key
        build_key(self.class.params_key)
      end

      def password_field
        self.class.password_field
      end

      # Tries to validate the session from information in the cookie
      def persist_by_cookie
        creds = cookie_credentials
        if creds&.persistence_token.present?
          record = search_for_record("find_by_#{klass.primary_key}", creds.record_id)
          if record && record.persistence_token == creds.persistence_token
            self.unauthorized_record = record
          end
          valid?
        else
          false
        end
      end

      def persist_by_params
        return false unless params_enabled?
        self.unauthorized_record = search_for_record(
          "find_by_single_access_token",
          params_credentials
        )
        self.single_access = valid?
      end

      def persist_by_http_auth
        login_proc = http_auth_login_proc

        if self.class.request_http_basic_auth
          controller.authenticate_or_request_with_http_basic(
            self.class.http_basic_auth_realm,
            &login_proc
          )
        else
          controller.authenticate_with_http_basic(&login_proc)
        end

        false
      end

      def persist_by_http_auth?
        allow_http_basic_auth? && login_field && password_field
      end

      # Tries to validate the session from information in the session
      def persist_by_session
        persistence_token, record_id = session_credentials
        if !persistence_token.nil?
          record = persist_by_session_search(persistence_token, record_id)
          if record && record.persistence_token == persistence_token
            self.unauthorized_record = record
          end
          valid?
        else
          false
        end
      end

      # Allow finding by persistence token, because when records are created
      # the session is maintained in a before_save, when there is no id.
      # This is done for performance reasons and to save on queries.
      def persist_by_session_search(persistence_token, record_id)
        if record_id.nil?
          search_for_record("find_by_persistence_token", persistence_token.to_s)
        else
          search_for_record("find_by_#{klass.primary_key}", record_id.to_s)
        end
      end

      def reset_stale_state
        self.stale_record = nil
      end

      def reset_perishable_token!
        if record.respond_to?(:reset_perishable_token) &&
            !record.disable_perishable_token_maintenance?
          record.reset_perishable_token
        end
      end

      # @api private
      def required_magic_states_for(record)
        %i[active approved confirmed].select { |state|
          record.respond_to?("#{state}?")
        }
      end

      def reset_failed_login_count?
        exceeded_failed_logins_limit? && !being_brute_force_protected?
      end

      def reset_failed_login_count
        attempted_record.failed_login_count = 0
      end

      # @api private
      def run_the_after_validation_callbacks
        run_callbacks(new_session? ? :after_validation_on_create : :after_validation_on_update)
        run_callbacks(:after_validation)
      end

      # @api private
      def run_the_before_validation_callbacks
        run_callbacks(:before_validation)
        run_callbacks(new_session? ? :before_validation_on_create : :before_validation_on_update)
      end

      # `args[0]` is the name of a model method, like
      # `find_by_single_access_token` or `find_by_smart_case_login_field`.
      def search_for_record(*args)
        search_scope.scoping do
          klass.send(*args)
        end
      end

      # Returns an AR relation representing the scope of the search. The
      # relation is either provided directly by, or defined by
      # `find_options`.
      def search_scope
        if scope[:find_options].is_a?(ActiveRecord::Relation)
          scope[:find_options]
        else
          conditions = scope[:find_options] && scope[:find_options][:conditions] || {}
          klass.send(:where, conditions)
        end
      end

      # @api private
      def set_last_request_at
        current_time = klass.default_timezone == :utc ? Time.now.utc : Time.now
        MagicColumn::AssignsLastRequestAt
          .new(current_time, record, controller, last_request_at_threshold)
          .assign
      end

      def single_access?
        single_access == true
      end

      def single_access_allowed_request_types
        self.class.single_access_allowed_request_types
      end

      def save_cookie
        cookie_jar[cookie_key] = generate_cookie_for_saving
      end

      # @api private
      # @return [String] - Examples:
      # - user_credentials_id
      # - ziggity_zack_user_credentials_id
      #   - ziggity_zack is an "id", see `#id`
      #   - see persistence_token_test.rb
      def session_compound_key
        "#{session_key}_#{klass.primary_key}"
      end

      def session_credentials
        [
          controller.session[session_key],
          controller.session[session_compound_key]
        ].collect { |i| i.nil? ? i : i.to_s }.compact
      end

      # @return [String] - Examples:
      # - user_credentials
      # - ziggity_zack_user_credentials
      #   - ziggity_zack is an "id", see `#id`
      #   - see persistence_token_test.rb
      def session_key
        build_key(self.class.session_key)
      end

      def update_info
        increment_login_cout
        clear_failed_login_count
        update_login_timestamps
        update_login_ip_addresses
      end

      def update_login_ip_addresses
        if record.respond_to?(:current_login_ip)
          record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
          record.current_login_ip = controller.request.ip
        end
      end

      def update_login_timestamps
        if record.respond_to?(:current_login_at)
          record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
          record.current_login_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
        end
      end

      def update_session
        update_session_set_persistence_token
        update_session_set_primary_key
      end

      # Updates the session, setting the primary key (usually `id`) of the
      # record.
      #
      # @api private
      def update_session_set_primary_key
        compound_key = session_compound_key
        controller.session[compound_key] = record && record.send(record.class.primary_key)
      end

      # Updates the session, setting the `persistence_token` of the record.
      #
      # @api private
      def update_session_set_persistence_token
        controller.session[session_key] = record && record.persistence_token
      end

      # In keeping with the metaphor of ActiveRecord, verification of the
      # password is referred to as a "validation".
      def validate_by_password
        self.invalid_password = false
        validate_by_password__blank_fields
        return if errors.count > 0
        self.attempted_record = search_for_record(find_by_login_method, send(login_field))
        if attempted_record.blank?
          add_login_not_found_error
          return
        end
        validate_by_password__invalid_password
      end

      def validate_by_password__blank_fields
        if send(login_field).blank?
          errors.add(
            login_field,
            I18n.t("error_messages.login_blank", default: "cannot be blank")
          )
        end
        if send("protected_#{password_field}").blank?
          errors.add(
            password_field,
            I18n.t("error_messages.password_blank", default: "cannot be blank")
          )
        end
      end

      # Verify the password, usually using `valid_password?` in
      # `acts_as_authentic/password.rb`. If it cannot be verified, we
      # refer to it as "invalid".
      def validate_by_password__invalid_password
        unless attempted_record.send(
          verify_password_method,
          send("protected_#{password_field}")
        )
          self.invalid_password = true
          add_invalid_password_error
        end
      end

      def validate_by_unauthorized_record
        self.attempted_record = unauthorized_record
      end

      def validate_magic_states
        return true if attempted_record.nil?
        required_magic_states_for(attempted_record).each do |required_status|
          next if attempted_record.send("#{required_status}?")
          errors.add(
            :base,
            I18n.t(
              "error_messages.not_#{required_status}",
              default: "Your account is not #{required_status}"
            )
          )
          return false
        end
        true
      end

      def validate_failed_logins
        # Clear all other error messages, as they are irrelevant at this point and can
        # only provide additional information that is not needed
        errors.clear
        duration = failed_login_ban_for == 0 ? "" : " temporarily"
        errors.add(
          :base,
          I18n.t(
            "error_messages.consecutive_failed_logins_limit_exceeded",
            default: format(
              "Consecutive failed logins limit exceeded, account has been%s disabled.",
              duration
            )
          )
        )
      end

      def verify_password_method
        self.class.verify_password_method
      end
    end
  end
end
