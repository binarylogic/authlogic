require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class CredentialsTest < ActiveSupport::TestCase
        def test_user_validations
          user = User.new
          assert !user.valid?
          assert user.errors.on(:login)
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.login = "a"
          assert !user.valid?
          assert user.errors.on(:login)
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.login = "%ben*"
          assert !user.valid?
          assert user.errors.on(:login)
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.login = "bjohnson"
          assert !user.valid?
          assert user.errors.on(:login)
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.login = "my login"
          assert !user.valid?
          assert !user.errors.on(:login)
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.password = "my pass"
          assert !user.valid?
          assert !user.errors.on(:password)
          assert user.errors.on(:password_confirmation)

          user.password_confirmation = "my pizass"
          assert !user.valid?
          assert user.errors.on(:password)
          assert user.errors.on(:email)

          user.password_confirmation = "my pass"
          assert !user.valid?
          assert user.errors.on(:email)
          
          user.email = "some email"
          assert !user.valid?
          assert user.errors.on(:email)
          
          user.email = "a@a.com"
          assert user.valid?
        end
        
        # Make sure the default :within option is ignored, since AR will raise an error if :within and :minimum are passed.
        def test_multiple_length_options
          User.acts_as_authentic(:login_field_validates_length_of_options => {:minimum => 6})
          user = User.new
          assert_nothing_raised { user.valid? }
        end
        
        def test_employee_validations
          employee = Employee.new
          employee.password = "pass"
          employee.password_confirmation = "pass"

          assert !employee.valid?
          assert employee.errors.on(:email)

          employee.email = "fdsf"
          assert !employee.valid?
          assert employee.errors.on(:email)

          employee.email = "fake@email.fake"
          assert !employee.valid?
          assert employee.errors.on(:email)

          employee.email = "notfake@email.com"
          assert employee.valid?
        end
        
        def test_friendly_unique_token
          assert_equal 20, User.friendly_unique_token.length
          assert_equal 20, Employee.friendly_unique_token.length # make sure encryptions use hashes also

          unique_tokens = []
          1000.times { unique_tokens << User.friendly_unique_token }
          unique_tokens.uniq!

          assert_equal 1000, unique_tokens.size
        end
        
        def test_password
          user = User.new
          user.password = "sillywilly"
          assert user.crypted_password
          assert user.password_salt
          assert user.persistence_token
          assert_equal "sillywilly", user.password

          employee = Employee.new
          employee.password = "awesome"
          assert employee.crypted_password
          assert employee.persistence_token
          assert_equal "awesome", employee.password
        end

        def test_valid_password
          ben = users(:ben)
          assert ben.valid_password?("benrocks")
          assert !ben.valid_password?(ben.crypted_password)

          drew = employees(:drew)
          assert drew.valid_password?("drewrocks")
          assert !drew.valid_password?(drew.crypted_password)
        end
        
        def test_reset_password
          ben = users(:ben)
          UserSession.create(ben)
          assert UserSession.find
          
          old_password = ben.crypted_password
          old_salt = ben.password_salt
          old_persistence_token = ben.persistence_token
          ben.reset_password
          assert_not_equal old_password, ben.crypted_password
          assert_not_equal old_salt, ben.password_salt
          assert_not_equal old_persistence_token, ben.persistence_token
          assert UserSession.find
        end
        
        def test_reset_password!
          UserSession.create(users(:ben))
          session = UserSession.find
          assert session
          ben = session.record
          
          old_password = ben.crypted_password
          old_salt = ben.password_salt
          old_persistence_token = ben.persistence_token
          ben.reset_password!
          ben.reload
          assert_not_equal old_password, ben.crypted_password
          assert_not_equal old_salt, ben.password_salt
          assert_not_equal old_persistence_token, ben.persistence_token
          assert !UserSession.find
        end
      end
    end
  end
end