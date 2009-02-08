require File.dirname(__FILE__) + '/../../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    module ActsAsAuthenticTests
      class ConfigTest < ActiveSupport::TestCase
        setup :get_default_configuration
        teardown :restore_default_configuration
        
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
            :password_field_validates_length_of_options => {},
            :password_field => :password,
            :validate_login_field => true,
            :email_field => :email,
            :perishable_token_field => :perishable_token,
            :password_field_validates_confirmation_of_options => {},
            :validate_email_field => true,
            :validation_options => {},
            :login_field_validation_options => {},
            :transition_from_crypto_provider => [],
            :password_confirmation_field_validates_presence_of_options => {}
           }
          assert_equal default_config, User.acts_as_authentic_config
        end
        
        def test_session_class
          EmployeeSession.authenticate_with User
          User.acts_as_authentic(:session_class => EmployeeSession)
          assert_equal EmployeeSession, User.acts_as_authentic_config[:session_class]
          
          ben = users(:ben)
          assert !EmployeeSession.find
          ben.password = "benrocks"
          ben.password_confirmation = "benrocks"
          assert ben.save
          assert EmployeeSession.find
          EmployeeSession.authenticate_with Employee
        end
        
        def test_crypto_provider
          User.acts_as_authentic(:crypto_provider => Authlogic::CryptoProviders::BCrypt)
          ben = users(:ben)
          assert !ben.valid_password?("benrocks")
          ben.password = "benrocks"
          ben.password_confirmation = "benrocks"
          assert ben.save
          assert ben.valid_password?("benrocks")
        end
        
        def test_transition_from_crypto_provider
          ben = users(:ben)
          convert_password_to(Authlogic::CryptoProviders::BCrypt, ben)
          convert_password_to(Authlogic::CryptoProviders::Sha1, ben, [Authlogic::CryptoProviders::Sha512, Authlogic::CryptoProviders::BCrypt])
          convert_password_to(Authlogic::CryptoProviders::Sha512, ben, [Authlogic::CryptoProviders::Sha1, Authlogic::CryptoProviders::BCrypt])
        end
        
        def test_act_like_restful_authentication
          ben = users(:ben)
          convert_password_to(Authlogic::CryptoProviders::Sha1, ben)
          User.acts_as_authentic(:act_like_restful_authentication => true)
          set_session_for(ben)
          assert UserSession.find
          
          # Let's try a brute force approach
          salt = "7e3041ebc2fc05a40c60028e2c4901a81035d3cd"
          digest = "00742970dc9e6319f8019fd54864d3ea740f04b1"
          assert ben.class.connection.execute("update users set crypted_password = '#{digest}', password_salt = '#{salt}' where id = '#{ben.id}';")
          ben.reload
          assert_equal 1, Authlogic::CryptoProviders::Sha1.stretches
          assert ben.valid_password?("test")
        end
        
        def test_transition_from_restful_authentication
          User.acts_as_authentic(:transition_from_restful_authentication => true)
          assert_equal Authlogic::CryptoProviders::Sha512, User.acts_as_authentic_config[:crypto_provider]
          assert_equal [Authlogic::CryptoProviders::Sha1], User.acts_as_authentic_config[:transition_from_crypto_provider]
        end
        
        # Need to finish this when I can figure out the best way to implement "transactions" for ruby constants inbetween tests
        def test_password_field_validation_options
          #User.acts_as_authentic(:password_field_validates_length_of_options => {:if => Proc.new { |user| false }})
          #user = User.new
          #assert !user.save!
          #assert !user.errors.on(:password)
        end
        
        def test_disable_perishable_token_maintenance
          ben = users(:ben)
          assert !ben.disable_perishable_token_maintenance?
          User.acts_as_authentic(:disable_perishable_token_maintenance => true)
          assert ben.disable_perishable_token_maintenance?
          old_perishable_token = ben.perishable_token
          assert ben.valid?
          assert_equal old_perishable_token, ben.perishable_token
        end
        
        private
          def get_default_configuration
            @default_configuration = User.acts_as_authentic_config
          end
          
          def restore_default_configuration
            User.acts_as_authentic @default_configuration
          end
          
          def convert_password_to(crypto_provider, records, from_crypto_providers = Authlogic::CryptoProviders::Sha512)
            records = [records] unless records.is_a?(Array)
            User.acts_as_authentic(:crypto_provider => crypto_provider, :transition_from_crypto_provider => from_crypto_providers)
            records.each do |record|
              old_hash = record.crypted_password
              old_persistence_token = record.persistence_token
              assert record.valid_password?(password_for(record))
              assert_not_equal old_hash.to_s, record.crypted_password.to_s
              assert_not_equal old_persistence_token.to_s, record.persistence_token.to_s # we need to make sure the persistence token gets reset, what if it is nil and has never been used before?
              
              old_hash = record.crypted_password
              old_persistence_token = record.persistence_token
              assert record.valid_password?(password_for(record))
              assert_equal old_hash.to_s, record.crypted_password.to_s
              assert_equal old_persistence_token.to_s, record.persistence_token.to_s
            end
          end
      end
    end
  end
end