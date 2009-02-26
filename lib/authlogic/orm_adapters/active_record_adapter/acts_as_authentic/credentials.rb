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
              email_name_regex  = '[\w\.%\+\-]+'
              domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
              domain_tld_regex  = '(?:[A-Z]{2}|aero|ag|asia|at|be|biz|ca|cc|cn|com|de|edu|eu|fm|gov|gs|jobs|jp|in|info|me|mil|mobi|museum|ms|name|net|nu|nz|org|tc|tw|tv|uk|us|vg|ws)'
              email_field_regex ||= /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
              
              if options[:validate_login_field]
                case options[:login_field_type]
                when :email
                  validates_length_of options[:login_field], sanitize_validation_length_options({:within => 6..100}, options[:login_field_validates_length_of_options])
                  validates_format_of options[:login_field], {:with => email_field_regex, :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address.")}.merge(options[:login_field_validates_format_of_options])
                else
                  validates_length_of options[:login_field], sanitize_validation_length_options({:within => 2..100}, options[:login_field_validates_length_of_options])
                  validates_format_of options[:login_field], {:with => /\A\w[\w\.\-_@ ]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, spaces, and .-_@ please.")}.merge(options[:login_field_validates_format_of_options])
                end
                
                validates_uniqueness_of options[:login_field], {:allow_blank => true}.merge(options[:login_field_validates_uniqueness_of_options].merge(:if => "#{options[:login_field]}_changed?".to_sym))
              end
              
              if options[:validate_password_field]
                validates_length_of options[:password_field], sanitize_validation_length_options({:minimum => 4}, options[:password_field_validates_length_of_options].merge(:if => "validate_#{options[:password_field]}?".to_sym))
                validates_confirmation_of options[:password_field], options[:password_field_validates_confirmation_of_options].merge(:if => "#{options[:password_salt_field]}_changed?".to_sym)
                validates_presence_of "#{options[:password_field]}_confirmation", options[:password_confirmation_field_validates_presence_of_options].merge(:if => "#{options[:password_salt_field]}_changed?".to_sym)
              end
              
              if options[:validate_email_field] && options[:email_field]
                validates_length_of options[:email_field], sanitize_validation_length_options({:within => 6..100}, options[:email_field_validates_length_of_options])
                validates_format_of options[:email_field], {:with => email_field_regex, :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address.")}.merge(options[:email_field_validates_format_of_options])
                validates_uniqueness_of options[:email_field], options[:email_field_validates_uniqueness_of_options].merge(:if => "#{options[:email_field]}_changed?".to_sym)
              end
            end
            
            attr_accessor "validate_#{options[:password_field]}".to_sym
            attr_reader options[:password_field]
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              def self.friendly_unique_token
                Authlogic::Random.friendly_token
              end
              
              def #{options[:password_field]}=(pass)
                return if pass.blank?
                @#{options[:password_field]} = pass
                self.#{options[:password_salt_field]} = self.class.unique_token
                self.#{options[:crypted_password_field]} = #{options[:crypto_provider]}.encrypt(*encrypt_arguments(@#{options[:password_field]}, #{options[:act_like_restful_authentication].inspect} ? :restful_authentication : nil))
              end
              
              def valid_#{options[:password_field]}?(attempted_password)
                return false if attempted_password.blank? || #{options[:crypted_password_field]}.blank? || #{options[:password_salt_field]}.blank?
                
                ([#{options[:crypto_provider]}] + #{options[:transition_from_crypto_provider].inspect}).each_with_index do |encryptor, index|
                  # The arguments_type of for the transitioning from restful_authentication
                  arguments_type = (#{options[:act_like_restful_authentication].inspect} && index == 0) ||
                    (#{options[:transition_from_restful_authentication].inspect} && index > 0 && encryptor == Authlogic::CryptoProviders::Sha1) ?
                    :restful_authentication : nil
                  
                  if encryptor.matches?(#{options[:crypted_password_field]}, *encrypt_arguments(attempted_password, arguments_type))
                    # If we are transitioning from an older encryption algorithm and the password is still using the old algorithm
                    # then let's reset the password using the new algorithm. If the algorithm has a cost (BCrypt) and the cost has changed, update the password with
                    # the new cost.
                    if index > 0 || (encryptor.respond_to?(:cost_matches?) && !encryptor.cost_matches?(#{options[:crypted_password_field]}))
                      self.password = attempted_password
                      save(false)
                    end
                    
                    return true
                  end
                end
                
                false
              end
              
              def reset_#{options[:password_field]}
                friendly_token = self.class.friendly_unique_token
                self.#{options[:password_field]} = friendly_token
                self.#{options[:password_field]}_confirmation = friendly_token
              end
              alias_method :randomize_#{options[:password_field]}, :reset_#{options[:password_field]}
              
              def confirm_#{options[:password_field]}
                raise "confirm_#{options[:password_field]} has been removed, please use #{options[:password_field]}_confirmation. " +
                  "As this is the field that ActiveRecord automatically creates with validates_confirmation_of."
              end
              
              def reset_#{options[:password_field]}!
                reset_#{options[:password_field]}
                save_without_session_maintenance(false)
              end
              alias_method :randomize_#{options[:password_field]}!, :reset_#{options[:password_field]}!
              
              def validate_#{options[:password_field]}?
                case #{options[:password_field_validates_length_of_options][:if].inspect}
                when String
                  return false if !eval('#{options[:password_field_validates_length_of_options][:if]}')
                when Symbol
                  return false if !send(#{options[:password_field_validates_length_of_options][:if].inspect})
                end
                
                new_record? || #{options[:password_salt_field]}_changed? || #{options[:crypted_password_field]}.blank? || ["true", "1", "yes"].include?(validate_#{options[:password_field]}.to_s)
              end
              
              private
                def encrypt_arguments(raw_password, arguments_type = nil)
                  case arguments_type
                  when :restful_authentication
                    [REST_AUTH_SITE_KEY, #{options[:password_salt_field]}, raw_password, REST_AUTH_SITE_KEY]
                  else
                    [raw_password, #{options[:password_salt_field]}]
                  end
                end
            end_eval
          end
          
          def sanitize_validation_length_options(defaults, options)
            length_keys = [:minimum, :maximum, :in, :within, :is]
            length_keys.each { |key| defaults.delete(key) } if options.keys.find { |key| length_keys.include?(key.to_sym) }
            defaults.merge(options)
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