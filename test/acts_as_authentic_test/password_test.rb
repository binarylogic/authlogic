require 'test_helper'

module ActsAsAuthenticTest
  class PasswordTest < ActiveSupport::TestCase
    # If test_human_name is executed after test_i18n_of_human_name the test will fail.
    i_suck_and_my_tests_are_order_dependent!

    def test_crypted_password_field_config
      assert_equal :crypted_password, User.crypted_password_field
      assert_equal :crypted_password, Employee.crypted_password_field

      User.crypted_password_field = :nope
      assert_equal :nope, User.crypted_password_field
      User.crypted_password_field :crypted_password
      assert_equal :crypted_password, User.crypted_password_field
    end

    def test_password_salt_field_config
      assert_equal :password_salt, User.password_salt_field
      assert_equal :password_salt, Employee.password_salt_field

      User.password_salt_field = :nope
      assert_equal :nope, User.password_salt_field
      User.password_salt_field :password_salt
      assert_equal :password_salt, User.password_salt_field
    end

    def test_ignore_blank_passwords_config
      assert User.ignore_blank_passwords
      assert Employee.ignore_blank_passwords

      User.ignore_blank_passwords = false
      refute User.ignore_blank_passwords
      User.ignore_blank_passwords true
      assert User.ignore_blank_passwords
    end

    def test_check_passwords_against_database
      assert User.check_passwords_against_database
      User.check_passwords_against_database = false
      refute User.check_passwords_against_database
      User.check_passwords_against_database true
      assert User.check_passwords_against_database
    end

    def test_validate_password_field_config
      assert User.validate_password_field
      assert Employee.validate_password_field

      User.validate_password_field = false
      refute User.validate_password_field
      User.validate_password_field true
      assert User.validate_password_field
    end

    def test_validates_length_of_password_field_options_config
      default = { minimum: 8, if: :require_password? }
      assert_equal default, User.validates_length_of_password_field_options
      assert_equal default, Employee.validates_length_of_password_field_options

      User.validates_length_of_password_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_length_of_password_field_options)
      User.validates_length_of_password_field_options default
      assert_equal default, User.validates_length_of_password_field_options
    end

    def test_validates_confirmation_of_password_field_options_config
      default = { if: :require_password? }
      assert_equal default, User.validates_confirmation_of_password_field_options
      assert_equal default, Employee.validates_confirmation_of_password_field_options

      User.validates_confirmation_of_password_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_confirmation_of_password_field_options)
      User.validates_confirmation_of_password_field_options default
      assert_equal default, User.validates_confirmation_of_password_field_options
    end

    def test_validates_length_of_password_confirmation_field_options_config
      default = { minimum: 8, if: :require_password? }
      assert_equal default, User.validates_length_of_password_confirmation_field_options
      assert_equal default, Employee.validates_length_of_password_confirmation_field_options

      User.validates_length_of_password_confirmation_field_options = { yes: "no" }
      assert_equal({ yes: "no" }, User.validates_length_of_password_confirmation_field_options)
      User.validates_length_of_password_confirmation_field_options default
      assert_equal default, User.validates_length_of_password_confirmation_field_options
    end

    def test_crypto_provider_config
      assert_equal Authlogic::CryptoProviders::SCrypt, User.crypto_provider
      assert_equal Authlogic::CryptoProviders::AES256, Employee.crypto_provider

      User.crypto_provider = Authlogic::CryptoProviders::BCrypt
      assert_equal Authlogic::CryptoProviders::BCrypt, User.crypto_provider
      User.crypto_provider Authlogic::CryptoProviders::Sha512
      assert_equal Authlogic::CryptoProviders::Sha512, User.crypto_provider
    end

    def test_transition_from_crypto_providers_config
      assert_equal [Authlogic::CryptoProviders::Sha512], User.transition_from_crypto_providers
      assert_equal [], Employee.transition_from_crypto_providers

      User.transition_from_crypto_providers = [Authlogic::CryptoProviders::BCrypt]
      assert_equal [Authlogic::CryptoProviders::BCrypt], User.transition_from_crypto_providers
      User.transition_from_crypto_providers []
      assert_equal [], User.transition_from_crypto_providers
    end

    def test_validates_length_of_password
      u = User.new(login: "abcde", email: "abcde@test.com", password: "abcdefgh", password_confirmation: "abcdefgh")
      assert u.valid?

      u.password = u.password_confirmation = "abcdef"
      refute u.valid?

      assert u.errors[:password].include?("is too short (minimum is 8 characters)")
      assert u.errors[:password_confirmation].include?("is too short (minimum is 8 characters)")
    end

    def test_validates_confirmation_of_password
      u = User.new(login: "abcde", email: "abcde@test.com", password: "abcdefgh", password_confirmation: "abcdefgh")
      assert u.valid?

      u.password_confirmation = "abcdefghij"
      refute u.valid?

      assert u.errors[:password_confirmation].include?("doesn't match Password")
    end

    def test_validates_length_of_password_confirmation
      u = User.new

      u.password = "testpass"
      u.password_confirmation = ""
      refute u.valid?
      refute u.errors[:password_confirmation].empty?

      u.password_confirmation = "testpass"
      refute u.valid?
      assert u.errors[:password_confirmation].empty?

      ben = users(:ben)
      assert ben.valid?

      ben.password = "newpasswd"
      refute ben.valid?
      refute ben.errors[:password_confirmation].empty?

      ben.password_confirmation = "newpasswd"
      assert ben.valid?
    end

    def test_password
      u = User.new
      old_password_salt = u.password_salt
      old_crypted_password = u.crypted_password
      u.password = "test"
      assert_not_equal old_password_salt, u.password_salt
      assert_not_equal old_crypted_password, u.crypted_password
    end

    def test_transitioning_password
      ben = users(:ben)

      transition_password_to(Authlogic::CryptoProviders::BCrypt, ben)
      transition_password_to(
        Authlogic::CryptoProviders::Sha1,
        ben,
        [Authlogic::CryptoProviders::Sha512, Authlogic::CryptoProviders::BCrypt]
      )
      transition_password_to(
        Authlogic::CryptoProviders::Sha512,
        ben,
        [Authlogic::CryptoProviders::Sha1, Authlogic::CryptoProviders::BCrypt]
      )
    end

    def test_checks_password_against_database
      ben = users(:aaron)
      ben.password = "new pass"
      refute ben.valid_password?("new pass")
      assert ben.valid_password?("aaronrocks")
    end

    def test_checks_password_against_database_and_always_fails_on_new_records
      user = User.new
      user.password = "new pass"
      refute user.valid_password?("new pass")
    end

    def test_checks_password_against_object
      ben = users(:ben)
      ben.password = "new pass"
      assert ben.valid_password?("new pass", false)
      refute ben.valid_password?("benrocks", false)
    end

    def test_reset_password
      ben = users(:ben)
      old_crypted_password = ben.crypted_password
      old_password_salt = ben.password_salt

      # soft reset
      ben.reset_password
      assert_not_equal old_crypted_password, ben.crypted_password
      assert_not_equal old_password_salt, ben.password_salt

      # make sure it didn't go into the db
      ben.reload
      assert_equal old_crypted_password, ben.crypted_password
      assert_equal old_password_salt, ben.password_salt

      # hard reset
      assert ben.reset_password!
      assert_not_equal old_crypted_password, ben.crypted_password
      assert_not_equal old_password_salt, ben.password_salt

      # make sure it did go into the db
      ben.reload
      assert_not_equal old_crypted_password, ben.crypted_password
      assert_not_equal old_password_salt, ben.password_salt
    end

    private

      def transition_password_to(crypto_provider, records, from_crypto_providers = Authlogic::CryptoProviders::Sha512)
        records = [records] unless records.is_a?(Array)
        User.acts_as_authentic do |c|
          c.crypto_provider = crypto_provider
          c.transition_from_crypto_providers = from_crypto_providers
        end
        records.each do |record|
          old_hash = record.crypted_password
          old_persistence_token = record.persistence_token
          assert record.valid_password?(password_for(record))
          assert_not_equal old_hash.to_s, record.crypted_password.to_s
          assert_not_equal old_persistence_token.to_s, record.persistence_token.to_s

          old_hash = record.crypted_password
          old_persistence_token = record.persistence_token
          assert record.valid_password?(password_for(record))
          assert_equal old_hash.to_s, record.crypted_password.to_s
          assert_equal old_persistence_token.to_s, record.persistence_token.to_s
        end
      end
  end
end
