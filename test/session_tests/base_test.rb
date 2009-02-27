require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class BaseTest < ActiveSupport::TestCase
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
    
    def test_credentials
      session = UserSession.new
      session.credentials = {:login => "login", :password => "pass", :remember_me => true}
      assert_equal "login", session.login
      assert_nil session.password
      assert_equal "pass", session.send(:protected_password)
      assert_equal true, session.remember_me
      assert_equal({:password => "<Protected>", :login => "login"}, session.credentials)
    end
    
    def test_credentials_are_params_safe
      session = UserSession.new
      assert_nothing_raised { session.credentials = {:hacker_method => "error!"} }
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
    
    def test_find_record
      # tested thoroughly in test_find
    end
    
    def test_id
      ben = users(:ben)
      session = UserSession.new(ben, :my_id)
      assert_equal :my_id, session.id
      assert_equal "my_id_user_credentials", session.cookie_key
      assert_equal "my_id_user_credentials", session.session_key
    end
    
    def test_inspect
      session = UserSession.new
      assert_equal "#<UserSession #{{:login=>nil, :password=>"<protected>"}.inspect}>", session.inspect
      session.login = "login"
      session.password = "pass"
      assert "#<UserSession #{{:login=>"login", :password=>"<protected>"}.inspect}>" == session.inspect
    end
    
    def test_new_session
      session = UserSession.new
      assert session.new_session?
      
      set_session_for(users(:ben))
      session = UserSession.find
      assert !session.new_session?
    end
    
    def test_remember_me
      session = UserSession.new
      assert_nil session.remember_me
      assert !session.remember_me?
      
      session.remember_me = false
      assert_equal false, session.remember_me
      assert !session.remember_me?
      
      session.remember_me = true
      assert_equal true, session.remember_me
      assert session.remember_me?
      
      session.remember_me = nil
      assert_nil session.remember_me
      assert !session.remember_me?
      
      session.remember_me = "1"
      assert_equal "1", session.remember_me
      assert session.remember_me?
      
      session.remember_me = "true"
      assert_equal "true", session.remember_me
      assert session.remember_me?
    end
    
    def test_remember_me_until
      session = UserSession.new
      assert_nil session.remember_me_until
      
      session.remember_me = true
      assert 3.months.from_now <= session.remember_me_until
    end
    
    def test_save_with_nothing
      session = UserSession.new
      assert !session.save
      assert session.new_session?
    end
    
    def test_save_with_credentials
      ben = users(:ben)
      session = UserSession.new(:login => ben.login, :password => "benrocks")
      assert session.save
      assert !session.new_session?
      assert_equal 1, session.record.login_count
      assert Time.now >= session.record.current_login_at
      assert_equal "1.1.1.1", session.record.current_login_ip
    end
    
    def test_save_with_record
      ben = users(:ben)
      session = UserSession.new(ben)
      assert session.save
      assert !session.new_session?
      assert_equal 1, session.record.login_count
      assert Time.now >= session.record.current_login_at
      assert_equal "1.1.1.1", session.record.current_login_ip
    end
    
    def test_save_with_block
      ben = users(:ben)
      session = UserSession.new(:login => ben.login, :password => "benrocks")
      block_result = session.save do |result|
        assert result
      end
      assert_equal session, block_result
      assert !session.new_session?
      assert_equal 1, session.record.login_count
      assert Time.now >= session.record.current_login_at
      assert_equal "1.1.1.1", session.record.current_login_ip
    end
    
    def test_save_with_bang
      session = UserSession.new
      assert_raise(Authlogic::Session::SessionInvalid) { session.save! }
      
      session.unauthorized_record = users(:ben)
      assert session.save!
    end
    
    def test_unauthorized_record
      session = UserSession.new
      ben = users(:ben)
      session.unauthorized_record = ben
      assert_equal ben, session.unauthorized_record
      assert_equal :unauthorized_record, session.authenticating_with
    end
    
    def test_valid
      session = UserSession.new
      assert !session.valid?
      assert_nil session.record
      assert session.errors.count > 0
      
      ben = users(:ben)
      session.unauthorized_record = ben
      assert session.valid?
      assert_equal ben, session.record
      assert session.errors.empty?
    end
    
    def test_valid_record
      session = UserSession.new
      ben = users(:ben)
      session.send(:record=, ben)
      assert session.send(:valid_record?)
      assert session.errors.empty?
      
      ben.update_attribute(:active, false)
      assert !session.send(:valid_record?) 
      assert session.errors.on_base.size > 0
      
      ben.active = true
      ben.approved = false
      ben.save
      assert !session.send(:valid_record?) 
      assert session.errors.on_base.size > 0
      
      ben.approved = true
      ben.confirmed = false
      ben.save
      assert !session.send(:valid_record?)
      assert session.errors.on_base.size > 0
      
      ben.approved = false
      ben.confirmed = false
      ben.active = false
      
      UserSession.disable_magic_states = true
      session = UserSession.new
      session.send(:record=, ben)
      assert session.send(:valid_record?)
    end
    
    def test_valid_http_auth
      ben = users(:ben)
      session = UserSession.new
      
      http_basic_auth_for { assert !session.valid_http_auth? }
      
      http_basic_auth_for(ben) do
        assert session.valid_http_auth?
        assert_equal ben, session.record
        assert_equal ben.login, session.login
        assert_equal "benrocks", session.send(:protected_password)
      end
    end
  end
end