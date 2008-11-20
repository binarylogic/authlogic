module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Credentials
        #
        # Handles any credential specific code, such as validating the login, encrpyting the password, etc.
        #
        # === Class Methods
        #
        # * <tt>friendly_unique_token</tt> - returns a random string of 20 alphanumeric characters. Used when resetting the password. This is a more user friendly token then a long Sha512 hash.
        #
        # === Instance Methods
        #
        # * <tt>{options[:password_field]}=(value)</tt> - encrypts a raw password and sets it to your crypted_password_field. Also sets the password_salt to a random token.
        # * <tt>valid_{options[:password_field]}?(password_to_check)</tt> - checks is the password is valid. The password passed must be the raw password, not encrypted.
        # * <tt>reset_{options[:password_field]}</tt> - resets the password using the friendly_unique_token class method
        # * <tt>reset_{options[:password_field]}!</tt> - calls reset_password and then saves the record
        module Credentials
          def acts_as_authentic_with_credentials(options = {})
            acts_as_authentic_without_credentials(options)
            
            if options[:validate_fields]
              if options[:validate_login_field]
                case options[:login_field_type]
                when :email
                  validates_length_of options[:login_field], :within => 6..100, :allow_blank => options[:allow_blank_login_and_password_fields]
                  validates_format_of options[:login_field], :with => options[:login_field_regex], :message => options[:login_field_regex_failed_message], :allow_blank => options[:allow_blank_login_and_password_fields]
                else
                  validates_length_of options[:login_field], :within => 2..100, :allow_blank => options[:allow_blank_login_and_password_field]
                  validates_format_of options[:login_field], :with => options[:login_field_regex], :message => options[:login_field_regex_failed_message], :allow_blank => options[:allow_blank_login_and_password_fields]
                end
                
                validates_uniqueness_of options[:login_field], :scope => options[:scope], :allow_blank => options[:allow_blank_login_and_password_fields], :if => Proc.new { |record| record.respond_to?("#{options[:login_field]}_changed?") && record.send("#{options[:login_field]}_changed?") }
              end
              
              if options[:validate_email_field] && options[:email_field]
                validates_length_of options[:email_field], :within => 6..100, :allow_blank => options[:allow_blank_email_field]
                validates_format_of options[:email_field], :with => options[:email_field_regex], :message => options[:email_field_regex_failed_message], :allow_blank => options[:allow_blank_email_field]
                validates_uniqueness_of options[:email_field], :scope => options[:scope], :allow_blank => options[:allow_blank_email_field], :if => Proc.new { |record| record.respond_to?("#{options[:email_field]}_changed?") && record.send("#{options[:email_field]}_changed?") }
              end
              
              validate :validate_password if options[:validate_password_field]
            end
            
            attr_writer "confirm_#{options[:password_field]}"
            attr_accessor "tried_to_set_#{options[:password_field]}"
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              def self.friendly_unique_token
                chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                newpass = ""
                1.upto(20) { |i| newpass << chars[rand(chars.size-1)] }
                newpass
              end
              
              def #{options[:password_field]}=(pass)
                return if pass.blank?
                self.tried_to_set_#{options[:password_field]} = true
                @#{options[:password_field]} = pass
                self.#{options[:password_salt_field]} = self.class.unique_token
                self.#{options[:crypted_password_field]} = #{options[:crypto_provider]}.encrypt(@#{options[:password_field]} + #{options[:password_salt_field]})
              end
              
              def valid_#{options[:password_field]}?(attempted_password)
                return false if attempted_password.blank? || #{options[:crypted_password_field]}.blank? || #{options[:password_salt_field]}.blank?
                (#{options[:crypto_provider]}.respond_to?(:decrypt) && #{options[:crypto_provider]}.decrypt(#{options[:crypted_password_field]}) == attempted_password + #{options[:password_salt_field]}) ||
                  (!#{options[:crypto_provider]}.respond_to?(:decrypt) && #{options[:crypto_provider]}.encrypt(attempted_password + #{options[:password_salt_field]}) == #{options[:crypted_password_field]})
              end
              
              def #{options[:password_field]}; end
              def confirm_#{options[:password_field]}; end
              
              def reset_#{options[:password_field]}
                friendly_token = self.class.friendly_unique_token
                self.#{options[:password_field]} = friendly_token
                self.confirm_#{options[:password_field]} = friendly_token
              end
              alias_method :randomize_password, :reset_password
              
              def reset_#{options[:password_field]}!
                reset_#{options[:password_field]}
                save_without_session_maintenance(false)
              end
              alias_method :randomize_password!, :reset_password!
                
              protected
                def tried_to_set_password?
                  tried_to_set_password == true
                end
                
                def validate_password
                  return if #{options[:allow_blank_login_and_password_fields].inspect} && @#{options[:password_field]}.blank? && @confirm_#{options[:password_field]}.blank?
                  
                  if new_record? || tried_to_set_#{options[:password_field]}?
                    if @#{options[:password_field]}.blank?
                      errors.add(:#{options[:password_field]}, #{options[:password_blank_message].inspect})
                    else
                      errors.add(:confirm_#{options[:password_field]}, #{options[:confirm_password_did_not_match_message].inspect}) if @confirm_#{options[:password_field]} != @#{options[:password_field]}
                    end
                  end
                end
            end_eval
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::Credentials
    alias_method_chain :acts_as_authentic, :credentials
  end
end