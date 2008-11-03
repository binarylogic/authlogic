require 'test_helper'

# I know these tests are not really integration tests, but since UserSessions deals with cookies, models, etc. It was easiest and best to test it via an integration.
class UserSessionTest < ActionController::IntegrationTest
  def test_activated
    UserSession.controller = nil
    assert !UserSession.activated?
    get new_user_session_url # reactive
    assert UserSession.activated?
  end
  
  def test_create
    assert !UserSession.create("unknown", "bad")
    assert UserSession.create("bjohnson", "benrocks")
    assert_raise(Authlogic::Session::SessionInvalid) { assert !UserSession.create!("unknown", "bad") }
    assert_nothing_raised { UserSession.create!("bjohnson", "benrocks") }
  end
  
  def test_klass
    assert_equal User, UserSession.klass
  end
  
  def test_klass_name
    assert_equal "User", UserSession.klass_name
  end
  
  def test_find
    assert_equal nil, UserSession.find
    assert_successful_login("bjohnson", "benrocks")
    assert UserSession.find
  end
  
  def test_initialize
    session = UserSession.new
    assert !session.valid?
    assert_equal nil, session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new(:secure)
    assert_equal :secure, session.id
    assert !session.valid?
    assert_equal nil, session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new("user", "pass")
    assert_equal nil, session.id
    assert !session.valid?
    assert_equal "user", session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new("user", "pass", :secure)
    assert_equal :secure, session.id
    assert !session.valid?
    assert_equal "user", session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new(:login => "user", :password => "pass")
    assert_equal nil, session.id
    assert !session.valid?
    assert_equal "user", session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new({:login => "user", :password => "pass"}, :secure)
    assert_equal :secure, session.id
    assert !session.valid?
    assert_equal "user", session.login
    assert_equal nil, session.unauthorized_record
    
    session = UserSession.new(users(:ben))
    assert_equal nil, session.id
    assert session.valid?
    assert_equal nil, session.login
    assert_equal users(:ben), session.unauthorized_record
    
    session = UserSession.new(users(:ben), :secure)
    assert_equal :secure, session.id
    assert session.valid?
    assert_equal nil, session.login
    assert_equal users(:ben), session.unauthorized_record
  end
  
  def test_credentials
    session = UserSession.new
    session.credentials = nil
    assert_equal({:login => nil, :password => "<Protected>"}, session.credentials)
    
    session = UserSession.new
    session.credentials = {:login => "ben"}
    assert_equal({:login => "ben", :password => "<Protected>"}, session.credentials)
    
    session = UserSession.new
    assert_nothing_raised { session.credentials = {:login => "ben", :random_field => "test"} }
    
    session = UserSession.new
    session.credentials = {:login => "ben", :password => "awesome"}
    assert_equal({:login => "ben", :password => "<Protected>"}, session.credentials)
    assert_equal "awesome", session.send(:protected_password)
  end
  
  def test_destroy
    # tested thoroughly in stories
  end
  
  def test_errors
    # don't need to go crazy here since we are using ActiveRecord's error class, which has been thorough tested there
    session = UserSession.new
    assert !session.valid?
    session.login = ""
    session.password = ""
    assert !session.valid?
    assert session.errors.on(:login)
    assert session.errors.on(:password)
  end
  
  def test_id
    session = UserSession.new
    assert_equal nil, session.id
    session.id = :secure
    assert_equal :secure, session.id
  end
  
  def test_inspect
    session = UserSession.new
    assert_equal "#<UserSession {:login=>nil, :password=>\"<protected>\"}>", session.inspect
    
    session = UserSession.new("user", "pass")
    assert_equal "#<UserSession {:login=>\"user\", :password=>\"<protected>\"}>", session.inspect
    
    session = UserSession.new(users(:ben))
    assert_equal "#<UserSession {:unauthorized_record=>\"<protected>\"}>", session.inspect
  end
  
  def test_new_session
    session = UserSession.new
    assert session.new_session?
    
    session.login = "bjohnson"
    session.password = "benrocks"
    session.save
    assert !session.new_session?
    
    assert_successful_login("bjohnson", "benrocks")
    session = UserSession.find
    assert !session.new_session?
  end
  
  def test_remember_me
    session = UserSession.new
    session.remember_me = true
    assert_equal 3.months, session.remember_me_for
    assert session.remember_me_until > Time.now
    
    session.remember_me = false
    assert_equal nil, session.remember_me_for
    assert_equal nil, session.remember_me_until
  end
  
  def test_save
    # tested thoroughly in stories and in create above
  end
end