require "authlogic/test_case/mock_cookie_jar"
require "authlogic/test_case/mock_request"
require "authlogic/test_case/mock_controller"

module Authlogic
  # This is a collection of methods and classes that help you easily test Authlogic. In fact, I use these same tools
  # to test the internals of Authlogic.
  #
  # Some important things to keep in mind when testing:
  #
  # Authlogic requires a "connection" to your controller. In the same manner that ActiveRecord requires a connection to
  # your database. It can't do anything until it gets connnected. That being said, Authlogic will raise an
  # Authlogic::Session::Activation::NotActivatedError any time you try to instantiate an object without a "connection".
  # So before you do anything with Authlogic, you need to connect it. Let's walk through how to do this in tests:
  #
  # === Functional tests
  #
  # You shouldn't have to do anything. Authlogic automatically sets a before_filter in your ApplicationController that
  # conntects Authlogic to the controller. So as soon as you make a request in your tests, it will connect Authlogic
  # for you.
  #
  # === Integration tests
  #
  # Again, just like functional tests, you don't have to do anything. As soon as you make a request, Authlogic will be
  # conntected.
  #
  # === Unit tests
  #
  # Now here is the tricky part of testing. Since there really is no controller here, you need to "fake" Authlogic into
  # thinking there is. Don't worry, because the this model takes care of this for you. Just do the following
  # in your test's setup and you are good to go:
  #
  #   setup :activate_authlogic
  #
  # activate_authlogic is a method provided to you by this TestCase module.
  #
  # You can even test off of this controller to make sure everything is good. For example:
  #
  #   ben = users(:ben)
  #   assert_nil controller.session["user_credentials"]
  #   assert UserSession.create(ben)
  #   assert_equal controller.session["user_credentials"], ben.persistence_token
  #
  # You also get the "controller" method to use in your tests as well. Now you have everything you need to properly test in unit tests.
  #
  # === How to use
  #
  # Just require the file in your test_helper.rb file.
  #
  #   require "authlogic/test_case"
  module TestCase
    # Activates authlogic with an Authlogic::TestCase::MockController object.
    def activate_authlogic
      Authlogic::Session::Base.controller = controller
    end
    
    # The Authlogic::TestCase::MockController object passed to Authlogic to activate it. You can access this in your test.
    # See the module description for an example.
    def controller
      @controller ||= Authlogic::TestCase::MockController.new
    end
  end
  
  ::Test::Unit::TestCase.send(:include, TestCase)
end