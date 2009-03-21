require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class BaseTest < ActiveSupport::TestCase
    def test_authenticate_with_config
      UserSession.authenticate_with = Employee
      assert_equal "Employee", UserSession.klass_name
      assert_equal Employee, UserSession.klass
    
      UserSession.authenticate_with User
      assert_equal "User", UserSession.klass_name
      assert_equal User, UserSession.klass
    end
    
    def test_activated
      assert UserSession.activated?
      Authlogic::Session::Base.controller = nil
      assert !UserSession.activated?
    end
    
    def test_controller
      Authlogic::Session::Base.controller = nil
      assert_nil Authlogic::Session::Base.controller
      thread1 = Thread.new do
        controller = MockController.new
        Authlogic::Session::Base.controller = controller
        assert_equal controller, Authlogic::Session::Base.controller
      end
      thread1.join

      assert_nil Authlogic::Session::Base.controller
      
      thread2 = Thread.new do
        controller = MockController.new
        Authlogic::Session::Base.controller = controller
        assert_equal controller, Authlogic::Session::Base.controller
      end
      thread2.join
      
      assert_nil Authlogic::Session::Base.controller
    end
    
    def test_create
      ben = users(:ben)
      assert !UserSession.create(:login => ben.login, :password => "badpw")
      assert UserSession.create(:login => ben.login, :password => "benrocks")
      assert_raise(Authlogic::Session::SessionInvalid) { UserSession.create!(:login => ben.login, :password => "badpw") }
      assert UserSession.create!(:login => ben.login, :password => "benrocks")
    end
    
    def test_find
      ben = users(:ben)
      assert !UserSession.find
      http_basic_auth_for(ben) { assert UserSession.find }
      set_cookie_for(ben)
      assert UserSession.find
      unset_cookie
      set_session_for(ben)
      session = UserSession.find
      assert session
    end
    
    def test_klass
      assert_equal User, UserSession.klass
    end
    
    def test_klass_name
      assert_equal "User", UserSession.klass_name
    end
    
    def test_record_method
      ben = users(:ben)
      set_session_for(ben)
      session = UserSession.find
      assert_equal ben, session.record
      assert_equal ben, session.user
    end
    
    def test_init
      UserSession.controller = nil
      assert_raise(Authlogic::Session::NotActivated) { UserSession.new }
      UserSession.controller = @controller
      
      session = UserSession.new
      assert session.respond_to?(:login)
      assert session.respond_to?(:login=)
      assert session.respond_to?(:password)
      assert session.respond_to?(:password=)
      assert session.respond_to?(:protected_password, true)
      
      session = UserSession.new(:my_id)
      assert_equal :my_id, session.id
      
      session = UserSession.new({:login => "login", :password => "pass", :remember_me => true}, :my_id)
      assert_equal "login", session.login
      assert_nil session.password
      assert_equal "pass", session.send(:protected_password)
      assert_equal true, session.remember_me
      assert_equal :my_id, session.id
      
      session = UserSession.new(users(:ben), true, :my_id)
      assert_nil session.login
      assert_nil session.password
      assert_nil session.send(:protected_password)
      assert session.remember_me
      assert_equal :my_id, session.id
      assert_equal users(:ben), session.unauthorized_record
    end
  
    def test_destroy
      ben = users(:ben)
      session = UserSession.new
      assert !session.valid?
      assert !session.errors.empty?
      assert session.destroy
      assert session.errors.empty?
      session.unauthorized_record = ben
      assert session.save
      assert session.record
      assert session.destroy
      assert !session.record
    end
    
    def test_errors
      session = UserSession.new
      assert session.errors.is_a?(Authlogic::Session::Errors)
    end
    
    def test_persisting
      # tested thoroughly in test_find
    end
    
    def test_id
      session = UserSession.new(users(:ben), :my_id)
      assert_equal :my_id, session.id
    end
    
    def test_inspect
      session = UserSession.new
      assert_equal "#<UserSession>", session.inspect
    end
    
    def test_new_session
      session = UserSession.new
      assert session.new_session?
      
      set_session_for(users(:ben))
      session = UserSession.find
      assert !session.new_session?
    end
    
    def test_save_with_nothing
      session = UserSession.new
      assert !session.save
      assert session.new_session?
    end
    
    def test_save_with_block
      ben = users(:ben)
      session = UserSession.new
      block_result = session.save do |result|
        assert !result
      end
      assert !block_result
      assert session.new_session?
    end
    
    def test_save_with_bang
      session = UserSession.new
      assert_raise(Authlogic::Session::SessionInvalid) { session.save! }
      
      session.unauthorized_record = users(:ben)
      assert_nothing_raised { session.save! }
    end
    
    def test_valid
      session = UserSession.new
      assert !session.valid?
      assert_nil session.record
      assert session.errors.count > 0
      
      ben = users(:ben)
      session.unauthorized_record = ben
      assert session.valid?
      assert_equal ben, session.attempted_record
      assert session.errors.empty?
    end
  end
end