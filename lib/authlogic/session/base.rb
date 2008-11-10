module Authlogic
  module Session # :nodoc:
    # = Base
    #
    # This is the muscle behind Authlogic. For detailed information on how to use this please refer to the README. For detailed method explanations see below.
    class Base
      include Config
      
      class << self
        # Returns true if a controller have been set and can be used properly. This MUST be set before anything can be done. Similar to how ActiveRecord won't allow you to do anything
        # without establishing a DB connection. By default this is done for you automatically, but if you are using Authlogic in a unique way outside of rails, you need to assign a controller
        # object to Authlogic via Authlogic::Session::Base.controller = obj.
        def activated?
          !controller.blank?
        end
        
        def controller=(value) # :nodoc:
          controllers[Thread.current] = value
        end
        
        def controller # :nodoc:
          controllers[Thread.current]
        end
        
        def reset_controllers!
          @@controllers = {}
        end
        
        # A convenince method. The same as:
        #
        #   session = UserSession.new
        #   session.create
        def create(*args)
          session = new(*args)
          session.save
        end
        
        # Same as create but calls create!, which raises an exception when authentication fails
        def create!(*args)
          session = new(*args)
          session.save!
        end
        
        # A convenience method for session.find_record. Finds your session by session, then cookie, and finally basic http auth. Perfect for that global before_filter to find your logged in user:
        #
        #   before_filter :load_user
        #
        #   def load_user
        #     @user_session = UserSession.find
        #     @current_user = @user_session && @user_session.record
        #   end
        #
        # Accepts a single parameter as the id. See initialize for more information on ids. Lastly, how it finds the session can be modified via configuration.
        def find(id = nil)
          args = [id].compact
          session = new(*args)
          return session if session.find_record
          nil
        end
        
        def klass # :nodoc:
          @klass ||=
            if klass_name
              klass_name.constantize
            else
              nil
            end
        end
        
        def klass_name # :nodoc:
          @klass_name ||= 
            if guessed_name = name.scan(/(.*)Session/)[0]
              @klass_name = guessed_name[0]
            end
        end
        
        private
          def controllers
            @@controllers ||= {}
          end
      end
    
      attr_accessor :login_with, :new_session
      attr_reader :record, :unauthorized_record
      attr_writer :id
    
      # You can initialize a session by doing any of the following:
      #
      #   UserSession.new
      #   UserSession.new(login, password)
      #   UserSession.new(:login => login, :password => password)
      #   UserSession.new(User.first)
      #
      # If a user has more than one session you need to pass an id so that Authlogic knows how to differentiate the sessions. The id MUST be a Symbol.
      #
      #   UserSession.new(:my_id)
      #   UserSession.new(login, password, :my_id)
      #   UserSession.new({:login => loing, :password => password}, :my_id)
      #   UserSession.new(User.first, :my_id)
      #
      # Ids are rarely used, but they can be useful. For example, what if users allow other users to login into their account via proxy? Now that user can "technically" be logged into 2 accounts at once.
      # To solve this just pass a id called :proxy, or whatever you want. Authlogic will separate everything out.
      def initialize(*args)
        raise NotActivated.new(self) unless self.class.activated?
        
        create_configurable_methods!
        
        self.id = args.pop if args.last.is_a?(Symbol)
        
        case args.first
        when Hash
          self.credentials = args.first
        when String
          send("#{login_field}=", args[0]) if args.size > 0
          send("#{password_field}=", args[1]) if args.size > 1
          self.remember_me = args[2] if args.size > 2
        else
          self.unauthorized_record = args.first
          self.remember_me = args[1] if args.size > 1
        end
      end
      
      # Your login credentials in hash format. Usually {:login => "my login", :password => "<protected>"} depending on your configuration.
      # Password is protected as a security measure. The raw password should never be publicly accessible.
      def credentials
        {login_field => send(login_field), password_field => "<Protected>"}
      end
      
      # Lets you set your loging and password via a hash format. This is "params" safe. It only allows for 3 keys: your login field name, password field name, and remember me.
      def credentials=(values)
        return if values.blank? || !values.is_a?(Hash)
        values.symbolize_keys!
        [login_field.to_sym, password_field.to_sym, :remember_me].each do |field|
          next if !values.key?(field)
          send("#{field}=", values[field])
        end
      end
      
      # Resets everything, your errors, record, cookies, and session. Basically "logs out" a user.
      def destroy
        errors.clear
        @record = nil
        true
      end
      
      # The errors in Authlogic work JUST LIKE ActiveRecord. In fact, it uses the exact same ActiveRecord errors class. Use it the same way:
      #
      # === Example
      #
      #  class UserSession
      #    before_validation :check_if_awesome
      #
      #    private
      #      def check_if_awesome
      #        errors.add(:login, "must contain awesome") if login && !login.include?("awesome")
      #        errors.add_to_base("You must be awesome to log in") unless record.awesome?
      #      end
      #  end
      def errors
        @errors ||= Errors.new(self)
      end
      
      # Attempts to find the record by session, then cookie, and finally basic http auth. See the class level find method if you are wanting to use this in a before_filter to persist your session.
      def find_record
        if record
          self.new_session = false
          return record
        end
        
        find_with.each do |find_method|
          if send("valid_#{find_method}?")
            self.new_session = false
            
            if record.class.column_names.include?("last_request_at") && (record.last_request_at.blank? || last_request_at_threshold.ago >= record.last_request_at)
              record.last_request_at = Time.now
              record.save_without_session_maintenance(false)
            end
            
            return record
          end
        end
        nil
      end
      
      # Allows you to set a unique identifier for your session, so that you can have more than 1 session at a time. A good example when this might be needed is when you want to have a normal user session
      # and a "secure" user session. The secure user session would be created only when they want to modify their billing information, or other sensative information. Similar to me.com. This requires 2
      # user sessions. Just use an id for the "secure" session and you should be good.
      #
      # You can set the id a number of ways:
      #
      #   session = Session.new(:secure)
      #   session = Session.new("username", "password", :secure)
      #   session = Session.new({:username => "username", :password => "password"}, :secure)
      #   session.id = :secure
      #
      # Just be sure and set your id before you validate / create / update your session.
      def id
        @id
      end
      
      def inspect # :nodoc:
        details = {}
        case login_with
        when :unauthorized_record
          details[:unauthorized_record] = "<protected>"
        else
          details[login_field.to_sym] = send(login_field)
          details[password_field.to_sym] = "<protected>"
        end
        "#<#{self.class.name} #{details.inspect}>"
      end
      
      # Returns true if logging in with credentials. Credentials mean username and password.
      def logging_in_with_credentials?
        login_with == :credentials
      end
      
      # Returns true if logging in with an unauthorized record
      def logging_in_with_unauthorized_record?
        login_with == :unauthorized_record
      end
      alias_method :logging_in_with_record?, :logging_in_with_unauthorized_record?
      
      # Similar to ActiveRecord's new_record? Returns true if the session has not been saved yet.
      def new_session?
        new_session != false
      end
      
      def remember_me # :nodoc:
        return @remember_me if @set_remember_me
        @remember_me ||= self.class.remember_me
      end
      
      # Accepts a boolean as a flag to remember the session or not. Basically to expire the cookie at the end of the session or keep it for "remember_me_until".
      def remember_me=(value)
        @set_remember_me = true
        @remember_me = value
      end
      
      # Allows users to be remembered via a cookie.
      def remember_me?
        remember_me == true || remember_me == "true" || remember_me == "1"
      end
      
      # When to expire the cookie. See remember_me_for configuration option to change this.
      def remember_me_until
        return unless remember_me?
        remember_me_for.from_now
      end
      
      # Creates / updates a new user session for you. It does all of the magic:
      #
      # 1. validates
      # 2. sets session
      # 3. sets cookie
      # 4. updates magic fields
      def save
        if valid?
          record.login_count = (record.login_count.blank? ? 1 : record.login_count + 1) if record.respond_to?(:login_count)
          
          if record.respond_to?(:current_login_at)
            record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
            record.current_login_at = Time.now
          end
          
          if record.respond_to?(:current_login_ip)
            record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
            record.current_login_ip = controller.request.remote_ip
          end
          
          record.save_without_session_maintenance(false)
          
          self.new_session = false
          self
        end
      end
      
      # Same as save but raises an exception when authentication fails
      def save!
        result = save
        raise SessionInvalid.new(self) unless result
        result
      end
      
      # Sometimes you don't want to create a session via credentials (login and password). Maybe you already have the record. Just set this record to this and it will be authenticated when you try to validate
      # the session. Basically this is another form of credentials, you are just skipping username and password validation.
      def unauthorized_record=(value)
        self.login_with = :unauthorized_record
        @unauthorized_record = value
      end
      
      # Returns if the session is valid or not. Basically it means that a record could or could not be found. If the session is valid you will have a result when calling the "record" method. If it was unsuccessful
      # you will not have a record.
      def valid?
        errors.clear
        if valid_credentials?
          validate
          valid_record?
          return true if errors.empty?
        end
        
        self.record = nil
        false
      end
      
      # Tries to validate the session from information from a basic http auth, if it was provided.
      def valid_http_auth?
        controller.authenticate_with_http_basic do |login, password|
          if !login.blank? && !password.blank?
            send("#{login_field}=", login)
            send("#{password_field}=", password)
            return valid?
          end
        end
        
        false
      end
      
      # Overwite this method to add your own validation, or use callbacks: before_validation, after_validation
      def validate
      end
      
      private
        def controller
          self.class.controller
        end
        
        def create_configurable_methods!
          return if respond_to?(login_field) # already created these methods
          
          self.class.class_eval <<-"end_eval", __FILE__, __LINE__
            attr_reader :#{login_field}
            
            def #{login_field}=(value)
              self.login_with = :credentials
              @#{login_field} = value
            end
            
            def #{password_field}=(value)
              self.login_with = :credentials
              @#{password_field} = value
            end

            def #{password_field}; end
            
            private
              # The password should not be accessible publicly. This way forms using form_for don't fill the password with the attempted password. The prevent this we just create this method that is private.
              def protected_#{password_field}
                @#{password_field}
              end
          end_eval
        end
        
        def klass
          self.class.klass
        end
      
        def klass_name
          self.class.klass_name
        end
        
        def record=(value)
          @record = value
        end
        
        def search_for_record(method, value)
          begin
            klass.send(method, value)
          rescue Exception
            raise method.inspect + "     " + value.inspect
          end
        end
        
        def valid_credentials?
          unchecked_record = nil
          
          case login_with
          when :credentials
            errors.add(login_field, "can not be blank") if send(login_field).blank?
            errors.add(password_field, "can not be blank") if send("protected_#{password_field}").blank?
            return false if errors.count > 0
            
            unchecked_record = search_for_record(find_by_login_method, send(login_field))
            
            if unchecked_record.blank?
              errors.add(login_field, "was not found")
              return false
            end
            
            unless unchecked_record.send(verify_password_method, send("protected_#{password_field}"))
              errors.add(password_field, "is invalid")
              return false
            end
          when :unauthorized_record
            unchecked_record = unauthorized_record
            
            if unchecked_record.blank?
              errors.add_to_base("The record could not be found and did not match the requirements.")
              return false
            end
            
            if unchecked_record.new_record?
              errors.add_to_base("You can not login with a new record.")
              return false
            end
          else
            errors.add_to_base("You must provide some form of credentials before logging in.")
            return false
          end
          
          self.record = unchecked_record
          true
        end
        
        def valid_record?
          [:active, :approved, :confirmed].each do |required_status|
            if record.respond_to?("#{required_status}?") && !record.send("#{required_status}?")
              errors.add_to_base("Your account has not been marked as #{required_status}")
              return false
            end
          end
        end
    end
  end
end