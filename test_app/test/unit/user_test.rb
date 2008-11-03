require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_validations
    user = User.new
    assert !user.valid?
    assert user.errors.on(:login)
    user.login = "^fds#%"
    assert !user.valid?
    assert user.errors.on(:login)
    user.login = "bjohnson"
    assert !user.valid?
    assert user.errors.on(:login)
    user.login = "unique"
    assert !user.valid?
    assert user.errors.on(:password)
    user.password = "awesome"
    assert !user.valid?
    assert user.errors.on(:confirm_password)
    user.confirm_password = "awesome"
    assert user.valid?
  end
  
  def test_unique_token
    tokens = []
    100.times { tokens << User.unique_token }
    assert_equal 100, tokens.uniq.size
  end
  
  def test_crypto_provider
    assert_equal Authlogic::Sha512CryptoProvider, User.crypto_provider
  end
  
  def test_forget_all
    bens_token = users(:ben).remember_token
    zacks_token = users(:zack).remember_token
    User.forget_all!
    assert_not_equal bens_token, users(:ben).reload.remember_token
    assert_not_equal zacks_token, users(:zack).reload.remember_token
  end
  
  def test_logged_in
    ben = users(:ben)
    assert !ben.logged_in?
    ben.update_attribute(:last_request_at, Time.now)
    assert ben.logged_in?
  end
  
  def test_password
    user = User.new
    user.password = "test"
    assert user.password_salt
    assert_equal User.crypto_provider.encrypt("test" + user.password_salt), user.crypted_password
    assert user.remember_token
  end
  
  def test_valid_password
    ben = users(:ben)
    assert ben.valid_password?("benrocks")
    assert ben.valid_password?(User.crypto_provider.encrypt("benrocks" + ben.password_salt))
  end
  
  def test_forget
    ben = users(:ben)
    token = ben.remember_token
    ben.forget!
    ben.reload
    assert_not_equal token, ben.remember_token
  end
  
  def test_randomize_password
    ben = users(:ben)
    crypted_password = ben.crypted_password
    password_salt = ben.password_salt
    ben.randomize_password!
    ben.reload
    assert_not_equal crypted_password, ben.crypted_password
    assert_not_equal password_salt, ben.password_salt
  end
end
