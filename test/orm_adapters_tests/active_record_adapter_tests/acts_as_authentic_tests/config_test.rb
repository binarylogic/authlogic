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
            :session_ids => [nil],
           :email_field_validates_length_of_options => {},
           :logged_in_timeout => 600,
           :validate_password_field => true,
           :login_field_validates_length_of_options => {},
           :password_field_validation_options => {},
           :login_field_type => :login,
           :email_field_validates_format_of_options => {},
           :crypted_password_field => :crypted_password,
           :password_salt_field => :password_salt,
           :login_field_validates_format_of_options => {},
           :email_field_validation_options => {},
           :crypto_provider => Authlogic::CryptoProviders::Sha512,
           :persistence_token_field => :persistence_token,
           :email_field_validates_uniqueness_of_options => {},
           :session_class => "UserSession",
           :single_access_token_field => :single_access_token,
           :login_field_validates_uniqueness_of_options => {},
           :validate_fields => true,
           :login_field => :login,
           :perishable_token_valid_for => 600,
           :password_field_validates_presence_of_options => {},
           :password_field => :password,
           :validate_login_field => true,
           :email_field => :email,
           :perishable_token_field => :perishable_token,
           :password_field_validates_confirmation_of_options => {},
           :validate_email_field => true,
           :validation_options => {},
           :login_field_validation_options => {}
           }
          assert_equal default_config, User.acts_as_authentic_config
        end
      end
    end
  end
end