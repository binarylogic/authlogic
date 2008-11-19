require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class ConfigTest < ActiveSupport::TestCase
        def test_first_column_to_exist
          assert_equal :login, User.first_column_to_exist(:login, :crypted_password)
          assert_equal nil, User.first_column_to_exist(nil, :unknown)
          assert_equal :login, User.first_column_to_exist(:unknown, :login)
        end
        
        def test_acts_as_authentic_config
          default_config = {
            :confirm_password_did_not_match_message => "did not match",
            :single_access_token_field => :single_access_token,
            :login_field_regex => /\A\w[\w\.\-_@ ]+\z/,
            :session_ids => [nil],
            :login_field_regex_failed_message => "use only letters, numbers, spaces, and .-_@ please.",
            :persistence_token_field => :persistence_token,
            :password_field => :password,
            :logged_in_timeout => 600,
            :password_salt_field => :password_salt,
            :perishable_token_valid_for => 600,
            :perishable_token_field => :perishable_token,
            :login_field_type => :login,
            :crypto_provider => Authlogic::CryptoProviders::Sha512,
            :password_blank_message => "can not be blank",
            :crypted_password_field => :crypted_password,
            :session_class => "UserSession",
            :login_field => :login,
            :email_field => :email,
            :email_field_regex => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i,
            :email_field_regex_failed_message=>"should look like an email address.",
            :validate_fields => true,
            :validate_login_field => true,
            :validate_email_field => true,
            :validate_password_field => true
          }
          assert_equal default_config, User.acts_as_authentic_config
        end
      end
    end
  end
end