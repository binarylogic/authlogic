require File.dirname(__FILE__) + "/test_case/rails_request_adapter"
require File.dirname(__FILE__) + "/test_case/mock_cookie_jar"
require File.dirname(__FILE__) + "/test_case/mock_controller"
require File.dirname(__FILE__) + "/test_case/mock_logger"
require File.dirname(__FILE__) + "/test_case/mock_request"

module Authlogic
  # This is a collection of methods and classes that help you easily test Authlogic. In fact, I use these same tools
  # to test the internals of Authlogic.
  #
  # Some important things to keep in mind when testing:
  #
  # Authlogic requires a "connection" to your controller to activate it. In the same manner that ActiveRecord requires a connection to
  # your database. It can't do anything until it gets connnected. That being said, Authlogic will raise an
  # Authlogic::Session::Activation::NotActivatedError any time you try to instantiate an object without a "connection".
  # So before you do anything with Authlogic, you need to activate / connect Authlogic. Let's walk through how to do this in tests:
  #
  # === Functional tests
  #
  # Activating Authlogic isn't a problem here, because making a request will activate Authlogic for you. The problem is
  # logging users in so they can access restricted areas. Solvin this is simple, just do this:
  #
  #   setup :activate_authlogic
  #
  # Now log users in using Authlogic:
  #
  #   UserSession.create(users(:whomever))
  #
  # Do this before you make your request and it will act as if that user is logged in.
  #
  # === Integration tests
  #
  # Again, just like functional tests, you don't have to do anything. As soon as you make a request, Authlogic will be
  # conntected.
  #
  # === Unit tests
  #
  # The only time you need to do any trickiness here is if you want to test Authlogic yourself. Maybe you added some custom
  # code or methods in your Session class. Maybe you are writing a plugin or a library that extends Authlogic. Whatever it is
  # you need to make sure your code is tested and working properly.
  #
  # That being said, in this environment there is no controller. So you need to "fake" Authlogic into
  # thinking there is. Don't worry, because the this module takes care of this for you. Just do the following
  # in your test's setup and you are good to go:
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
  # That's it.
  #
  # === How to use
  #
  # Just require the file in your test_helper.rb file.
  #
  #   require "authlogic/test_case"
  module TestCase
    # Activates authlogic so that you can use it in your tests. You should call this method in your test's setup. Ex:
    #
    #   setup :activate_authlogic
    def activate_authlogic
      Authlogic::Session::Base.controller = (@request && Authlogic::TestCase::RailsRequestAdapter.new(@request)) || controller
    end
    
    # The Authlogic::TestCase::MockController object passed to Authlogic to activate it. You can access this in your test.
    # See the module description for an example.
    def controller
      @controller ||= Authlogic::TestCase::MockController.new
    end
  end
  
  ::Test::Unit::TestCase.send(:include, TestCase)
end