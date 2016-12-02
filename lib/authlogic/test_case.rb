require File.dirname(__FILE__) + "/test_case/rails_request_adapter"
require File.dirname(__FILE__) + "/test_case/mock_cookie_jar"
require File.dirname(__FILE__) + "/test_case/mock_controller"
require File.dirname(__FILE__) + "/test_case/mock_logger"
require File.dirname(__FILE__) + "/test_case/mock_request"

module Authlogic
  # This module is a collection of methods and classes that help you easily test
  # Authlogic. In fact, I use these same tools to test the internals of
  # Authlogic.
  #
  # === The quick and dirty
  #
  #   require "authlogic/test_case" # include at the top of test_helper.rb
  #   setup :activate_authlogic # run before tests are executed
  #   UserSession.create(users(:whomever)) # logs a user in
  #
  # For a more detailed explanation, see below.
  #
  # === Setting up
  #
  # Authlogic comes with some simple testing tools. To get these, you need to
  # first require Authlogic's TestCase. If you are doing this in a rails app,
  # you would require this file at the top of your test_helper.rb file:
  #
  #   require "authlogic/test_case"
  #
  # If you are using Test::Unit::TestCase, the standard testing library that
  # comes with ruby, then you can skip this next part. If you are not, you need
  # to include the Authlogic::TestCase into your testing suite as follows:
  #
  #   include Authlogic::TestCase
  #
  # Now that everything is ready to go, let's move onto actually testing. Here
  # is the basic idea behind testing:
  #
  # Authlogic requires a "connection" to your controller to activate it. In the
  # same manner that ActiveRecord requires a connection to your database. It
  # can't do anything until it gets connected. That being said, Authlogic will
  # raise an Authlogic::Session::Activation::NotActivatedError any time you try
  # to instantiate an object without a "connection". So before you do anything
  # with Authlogic, you need to activate / connect Authlogic. Let's walk through
  # how to do this in tests:
  #
  # === Fixtures / Factories
  #
  # Creating users via fixtures / factories is easy. Here's an example of a
  # fixture:
  #
  #   ben:
  #     email: whatever@whatever.com
  #     password_salt: <%= salt = Authlogic::Random.hex_token %>
  #     crypted_password: <%= Authlogic::CryptoProviders::SCrypt.encrypt("benrocks" + salt) %>
  #     persistence_token: <%= Authlogic::Random.hex_token %>
  #     single_access_token: <%= Authlogic::Random.friendly_token %>
  #     perishable_token: <%= Authlogic::Random.friendly_token %>
  #
  # Notice the crypted_password value. Just supplement that with whatever crypto
  # provider you are using, if you are not using the default.
  #
  # === Functional tests
  #
  # Activating Authlogic isn't a problem here, because making a request will
  # activate Authlogic for you. The problem is logging users in so they can
  # access restricted areas. Solving this is simple, just do this:
  #
  #   setup :activate_authlogic
  #
  # For those of you unfamiliar with TestUnit, the setup method basically just
  # executes a method before any test is ran. It is essentially "setting up"
  # your tests.
  #
  # Once you have done this, just log users in like usual:
  #
  #   UserSession.create(users(:whomever))
  #   # access my restricted area here
  #
  # Do this before you make your request and it will act as if that user is
  # logged in.
  #
  # === Integration tests
  #
  # Again, just like functional tests, you don't have to do anything. As soon as
  # you make a request, Authlogic will be connected. If you want to activate
  # Authlogic before making a request follow the same steps described in the
  # "functional tests" section above. It works in the same manner.
  #
  # === Unit tests
  #
  # The only time you need to do any trickiness here is if you want to test
  # Authlogic models. Maybe you added some custom code or methods in your
  # Authlogic models. Maybe you are writing a plugin or a library that extends
  # Authlogic.
  #
  # That being said, in this environment there is no controller. So you need to
  # use a "mock" controller. Something that looks like a controller, acts like a
  # controller, but isn't a "real" controller. You are essentially connecting
  # Authlogic to your "mock" controller, then you can test off of the mock
  # controller to make sure everything is functioning properly.
  #
  # I use a mock controller to test Authlogic myself. It's part of the Authlogic
  # library that you can easily use. It's as simple as functional and
  # integration tests. Just do the following:
  #
  #   setup :activate_authlogic
  #
  # You also get a controller method that you can test off of. For example:
  #
  #   ben = users(:ben)
  #   assert_nil controller.session["user_credentials"]
  #   assert UserSession.create(ben)
  #   assert_equal controller.session["user_credentials"], ben.persistence_token
  #
  # See how I am checking that Authlogic is interacting with the controller
  # properly? That's the idea here.
  #
  # === Testing with Rails 5
  #
  # Rails 5 has [deprecated classic controller tests](https://goo.gl/4zmt6y).
  # Controller tests now inherit from `ActionDispatch::IntegrationTest` making
  # them plain old integration tests now. You have two options for testing
  # AuthLogic in Rails 5:
  #
  # * Add the `rails-controller-testing` gem to bring back the original
  #   controller testing usage
  # * Go full steam ahead with integration testing and actually log a user in
  #   by submitting a form in the integration test.
  #
  # Naturally DHH recommends the second method and this is
  # [what he does in his own tests](https://goo.gl/Ar6p0u). This is useful
  # for testing not only AuthLogic itself (submitting login credentials to a
  # UserSessionsController, for example) but any controller action that is
  # behind a login wall. Add a helper method and use that before testing your
  # actual controller action:
  #
  #   # test/test_helper.rb
  #   def login(user)
  #     post user_sessions_url, :params => { :email => user.email, :password => 'password' }
  #   end
  #
  #   # test/controllers/posts_controller_test.rb
  #   test "#create requires a user to be logged in
  #     post posts_url, :params => { :body => 'Lorem ipsum' }
  #
  #     assert_redirected_to new_user_session_url
  #   end
  #
  #   test "#create lets a logged in user create a new post" do
  #     login(users(:admin))
  #
  #     assert_difference 'Posts.count' do
  #       post posts_url, :params => { :body => 'Lorem ipsum' }
  #     end
  #
  #     assert_redirected_to posts_url
  #   end
  #
  # You still have access to the `session` helper in an integration test and so
  # you can still test to see if a user is logged in. A couple of helper methods
  # might look like:
  #
  #   # test/test_helper.rb
  #   def assert_logged_in
  #     assert session[:user_credentials].present?
  #   end
  #
  #   def assert_not_logged_in
  #     assert session[:user_credentials].blank?
  #   end
  #
  #   # test/user_sessions_controller_test.rb
  #   test "#create logs in a user" do
  #     login(users(:admin))
  #
  #     assert_logged_in
  #   end
  module TestCase
    # Activates authlogic so that you can use it in your tests. You should call
    # this method in your test's setup. Ex:
    #
    #   setup :activate_authlogic
    def activate_authlogic
      if @request && !@request.respond_to?(:params)
        class <<@request
          alias_method :params, :parameters
        end
      end

      Authlogic::Session::Base.controller = @request &&
        Authlogic::TestCase::RailsRequestAdapter.new(@request) ||
        controller
    end

    # The Authlogic::TestCase::MockController object passed to Authlogic to
    # activate it. You can access this in your test. See the module description
    # for an example.
    def controller
      @controller ||= Authlogic::TestCase::MockController.new
    end
  end

  ::Test::Unit::TestCase.send(:include, TestCase) if defined?(::Test::Unit::TestCase)
  ::MiniTest::Unit::TestCase.send(:include, TestCase) if defined?(::MiniTest::Unit::TestCase)
  ::MiniTest::Test.send(:include, TestCase) if defined?(::MiniTest::Test)
end
