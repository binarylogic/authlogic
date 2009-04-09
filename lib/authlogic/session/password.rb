module Authlogic
  module Session
    # Handles authenticating via a traditional username and password.
    module Password
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          validate :validate_by_password, :if => :authenticating_with_password?
          
          class << self
            attr_accessor :configured_password_methods
          end
        end
      end
      
      # Password configuration
      module Config
        # Authlogic tries to validate the credentials passed to it. One part of validation is actually finding the user and making sure it exists. What method it uses the do this is up to you.
        #
        # Let's say you have a UserSession that is authenticating a User. By default UserSession will call User.find_by_login(login). You can change what method UserSession calls by specifying it here. Then
        # in your User model you can make that method do anything you want, giving you complete control of how users are found by the UserSession.
        #
        # Let's take an example: You want to allow users to login by username or email. Set this to the name of the class method that does this in the User model. Let's call it "find_by_username_or_email"
        #
        #   class User < ActiveRecord::Base
        #     def self.find_by_username_or_email(login)
        #       find_by_username(login) || find_by_email(login)
        #     end
        #   end
        #
        # Now just specifcy the name of this method for this configuration option and you are all set. You can do anything you want here. Maybe you allow users to have multiple logins
        # and you want to search a has_many relationship, etc. The sky is the limit.
        #
        # * <tt>Default:</tt> "find_by_case_insensitive_#{login_field}"
        # * <tt>Accepts:</tt> Symbol or String
        def find_by_login_method(value = nil)
          config(:find_by_login_method, value, "find_with_#{login_field}")
        end
        alias_method :find_by_login_method=, :find_by_login_method
        
        # The name of the method you want Authlogic to create for storing the login / username. Keep in mind this is just for your
        # Authlogic::Session, if you want it can be something completely different than the field in your model. So if you wanted people to
        # login with a field called "login" and then find users by email this is compeltely doable. See the find_by_login_method configuration
        # option for more details.
        #
        # * <tt>Default:</tt> klass.login_field || klass.email_field
        # * <tt>Accepts:</tt> Symbol or String
        def login_field(value = nil)
          config(:login_field, value, klass.login_field || klass.email_field)
        end
        alias_method :login_field=, :login_field
        
        # Works exactly like login_field, but for the password instead. Returns :password if a login_field exists.
        #
        # * <tt>Default:</tt> :password
        # * <tt>Accepts:</tt> Symbol or String
        def password_field(value = nil)
          config(:password_field, value, login_field && :password)
        end
        alias_method :password_field=, :password_field
        
        # The name of the method in your model used to verify the password. This should be an instance method. It should also be prepared to accept a raw password and a crytped password.
        #
        # * <tt>Default:</tt> "valid_#{password_field}?"
        # * <tt>Accepts:</tt> Symbol or String
        def verify_password_method(value = nil)
          config(:verify_password_method, value, "valid_#{password_field}?")
        end
        alias_method :verify_password_method=, :verify_password_method
      end
      
      # Password related instance methods
      module InstanceMethods
        def initialize(*args)
          if !self.class.configured_password_methods
            if login_field
              self.class.send(:attr_writer, login_field) if !respond_to?("#{login_field}=")
              self.class.send(:attr_reader, login_field) if !respond_to?(login_field)
            end
            
            if password_field
              self.class.send(:attr_writer, password_field) if !respond_to?("#{password_field}=")
              self.class.send(:define_method, password_field) {} if !respond_to?(password_field)

              self.class.class_eval <<-"end_eval", __FILE__, __LINE__
                private
                  # The password should not be accessible publicly. This way forms using form_for don't fill the password with the attempted password. The prevent this we just create this method that is private.
                  def protected_#{password_field}
                    @#{password_field}
                  end
              end_eval
            end

            self.class.configured_password_methods = true
          end
          
          super
        end
        
        def credentials
          if authenticating_with_password?
            details = {}
            details[login_field.to_sym] = send(login_field)
            details[password_field.to_sym] = "<protected>"
            details
          else
            super
          end
        end
        
        def credentials=(value)
          super
          values = value.is_a?(Array) ? value : [value]
          if values.first.is_a?(Hash)
            values.first.with_indifferent_access.slice(login_field, password_field).each do |field, value|
              next if value.blank?
              send("#{field}=", value)
            end
          end
        end
        
        private
          def authenticating_with_password?
            login_field && (!send(login_field).nil? || !send("protected_#{password_field}").nil?)
          end
          
          def validate_by_password
            errors.add(login_field, I18n.t('error_messages.login_blank', :default => "can not be blank")) if send(login_field).blank?
            errors.add(password_field, I18n.t('error_messages.password_blank', :default => "can not be blank")) if send("protected_#{password_field}").blank?
            return if errors.count > 0

            self.attempted_record = search_for_record(find_by_login_method, send(login_field))

            if attempted_record.blank?
              errors.add(login_field, I18n.t('error_messages.login_not_found', :default => "does not exist"))
              return
            end

            if !attempted_record.send(verify_password_method, send("protected_#{password_field}"))
              errors.add(password_field, I18n.t('error_messages.password_invalid', :default => "is not valid"))
              return
            end
          end
          
          def find_by_login_method
            self.class.find_by_login_method
          end
          
          def login_field
            self.class.login_field
          end
          
          def password_field
            self.class.password_field
          end
          
          def verify_password_method
            self.class.verify_password_method
          end
      end
    end
  end
end