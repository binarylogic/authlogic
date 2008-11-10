module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module Credentials # :nodoc:
        def acts_as_authentic_with_credentials(options = {})
          acts_as_authentic_without_credentials(options)
          
          class_eval <<-"end_eval", __FILE__, __LINE__
            def self.login_field
              @login_field ||= #{options[:login_field].inspect} ||
              (column_names.include?("login") && :login) ||
              (column_names.include?("username") && :username) ||
              (column_names.include?("email") && :email) ||
              :login
            end

            def self.password_field
              @password_field ||= #{options[:password_field].inspect} ||
              (column_names.include?("password") && :password) ||
              (column_names.include?("pass") && :pass) ||
              :password
            end

            def self.crypted_password_field
              @crypted_password_field ||= #{options[:crypted_password_field].inspect} ||
              (column_names.include?("crypted_password") && :crypted_password) ||
              (column_names.include?("encrypted_password") && :encrypted_password) ||
              (column_names.include?("password_hash") && :password_hash) ||
              (column_names.include?("pw_hash") && :pw_hash) ||
              :crypted_password
            end

            def self.password_salt_field
              @password_salt_field ||= #{options[:password_salt_field].inspect} ||
              (column_names.include?("password_salt") && :password_salt) ||
              (column_names.include?("pw_salt") && :pw_salt) ||
              (column_names.include?("salt") && :salt) ||
              :password_salt
            end
          end_eval
          
          options[:crypto_provider] ||= CryptoProviders::Sha512
          options[:login_field_type] ||= login_field == :email ? :email : :login
          
          # Validations
          case options[:login_field_type]
          when :email
            validates_length_of login_field, :within => 6..100
            email_name_regex  = '[\w\.%\+\-]+'
            domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
            domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
            options[:login_field_regex] ||= /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
            options[:login_field_regex_message] ||= "should look like an email address."
            validates_format_of login_field, :with => options[:login_field_regex], :message => options[:login_field_regex_message]
          else
            validates_length_of login_field, :within => 2..100
            options[:login_field_regex] ||= /\A\w[\w\.\-_@ ]+\z/
            options[:login_field_regex_message] ||= "use only letters, numbers, spaces, and .-_@ please."
            validates_format_of login_field, :with => options[:login_field_regex], :message => options[:login_field_regex_message]
          end
          
          validates_uniqueness_of login_field, :scope => options[:scope]
          validate :validate_password
          
          attr_writer "confirm_#{password_field}"
          attr_accessor "tried_to_set_#{password_field}"
          
          class_eval <<-"end_eval", __FILE__, __LINE__
            def self.crypto_provider
              #{options[:crypto_provider]}
            end
            
            def crypto_provider
              self.class.crypto_provider
            end
            
            def #{password_field}=(pass)
              return if pass.blank?
              self.tried_to_set_#{password_field} = true
              @#{password_field} = pass
              self.#{password_salt_field} = self.class.unique_token
              self.#{crypted_password_field} = crypto_provider.encrypt(@#{password_field} + #{password_salt_field})
            end
        
            def valid_#{password_field}?(attempted_password)
              return false if attempted_password.blank? || #{crypted_password_field}.blank? || #{password_salt_field}.blank?
              attempted_password == #{crypted_password_field} ||
                (crypto_provider.respond_to?(:decrypt) && crypto_provider.decrypt(#{crypted_password_field}) == attempted_password + #{password_salt_field}) ||
                (!crypto_provider.respond_to?(:decrypt) && crypto_provider.encrypt(attempted_password + #{password_salt_field}) == #{crypted_password_field})
            end
      
            def #{password_field}; end
            def confirm_#{password_field}; end
            
            def reset_#{password_field}!
              chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
              newpass = ""
              1.upto(10) { |i| newpass << chars[rand(chars.size-1)] }
              self.#{password_field} = newpass
              self.confirm_#{password_field} = newpass
              save_without_session_maintenance(false)
            end
            alias_method :randomize_password!, :reset_password!
            
            protected
              def tried_to_set_password?
                tried_to_set_password == true
              end
        
              def validate_password
                if new_record? || tried_to_set_#{password_field}?
                  if @#{password_field}.blank?
                    errors.add(:#{password_field}, "can not be blank")
                  else
                    errors.add(:confirm_#{password_field}, "did not match") if @confirm_#{password_field} != @#{password_field}
                  end
                end
              end
          end_eval
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::Credentials
    alias_method_chain :acts_as_authentic, :credentials
  end
end