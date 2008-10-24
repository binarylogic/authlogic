module Authgasm
  module Session # :nodoc:
    # = Base
    #
    # This is the muscle behind Authgasm. For detailed information on how to use this please refer to the README. For detailed method explanations see below.
    class Base
      include Config
      
      class << self
        # Returns true if a controller have been set and can be used properly.
        def activated?
          !controller.blank?
        end
        
        def controller=(value) # :nodoc:
          controllers[Thread.current] = value
        end
        
        def controller # :nodoc:
          controllers[Thread.current]
        end
        
        # A convenince method. The same as:
        #
        #   session = UserSession.new
        #   session.create
        def create(*args)
          session = new(*args)
          session.create
        end
        
        # Same as create but calls create!, which raises an exception when authentication fails
        def create!(*args)
          session = new(*args)
          session.create!
        end
        
        # Finds your session by session, then cookie, and finally basic http auth. Perfect for that global before_filter to find your logged in user:
        #
        #   before_filter :load_user
        #
        #   def load_user
        #     @user_session = UserSession.find
        #     @current_user = @user_session && @user_session.record
        #   end
        #
        # Accepts a single parameter as the scope. See initialize for more information on scopes.
        def find(scope = nil)
          args = [scope].compact
          session = new(*args)
          return session if session.valid_session? || session.valid_cookie?(true) || session.valid_http_auth?(true)
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
        
        # Convenience method. The same as:
        #
        #   session = UserSession.new
        #   session.update
        def update(*args)
          session = new(*args)
          session.update
        end
        
        # The same as update but calls update!, which raises an exception when authentication fails
        def update!(*args)
          session = new(*args)
          session.update!
        end
        
        private
          def controllers
            @@controllers ||= {}
          end
      end
    
      attr_accessor :login_with, :remember_me, :scope
      attr_reader :record, :unauthorized_record
    
      # You can initialize a session by doing any of the following:
      #
      #   UserSession.new
      #   UserSession.new(login, password)
      #   UserSession.new(:login => login, :password => password)
      #
      # If a user has more than one session you need to pass a scope so that Authgasm knows how to differentiate the sessions. The scope MUST be a Symbol.
      #
      #   UserSession.new(:my_scope)
      #   UserSession.new(login, password, :my_scope)
      #   UserSession.new({:login => loing, :password => password}, :my_scope)
      #
      # Scopes are rarely used, but they can be useful. For example, what if users allow other users to login into their account via proxy? Now that user can "technically" be logged into 2 accounts at once.
      # To solve this just pass a scope called :proxy, or whatever you want. Authgasm will separate everything out.s
      def initialize(*args)
        create_configurable_methods!
        
        self.scope = args.pop if args.last.is_a?(Symbol)
        
        case args.size
        when 1
          credentials_or_record = args.first
          case credentials_or_record
          when Hash
            self.credentials = credentials_or_record
          else
            self.unauthorized_record = credentials_or_record
          end
        else
          send("#{login_field}=", args[0])
          send("#{password_field}=", args[1])
          self.remember_me = args[2]
        end
      end
      
      # Creates a new user session for you. It does all of the magic:
      #
      # 1. validates
      # 2. sets session
      # 3. sets cookie
      # 4. updates magic fields
      def create(updating = false)
        if valid?(true)
          cookies[cookie_key] = {
            :value => record.send(remember_token_field),
            :expires => remember_me? ? remember_me_for.from_now : nil
          }
          
          if !updating
            record.login_count = record.login_count + 1 if record.respond_to?(:login_count)
          
            if record.respond_to?(:current_login_at)
              record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
              record.current_login_at = Time.now
            end
          
            if record.respond_to?(:current_login_ip)
              record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
              record.current_login_ip = controller.request.remote_ip
            end
            
            record.saving_from_session = true
            record.save(false)
          end
          
          self
        end
      end
      
      # Same as create but raises an exception when authentication fails
      def create!(updating = false)
        raise SessionInvalid.new(self) unless create(updating)
      end
      alias_method :start!, :create!
      
      # Your login credentials in hash format. Usually {:login => "my login", :password => "<protected>"} depending on your configuration.
      # Password is protected as a security measure. The raw password should never be publicly accessible.
      def credentials
        {login_field => send(login_field), password_field => "<Protected>"}
      end
      
      # Lets you set your loging and password via a hash format.
      def credentials=(values)
        values.symbolize_keys!
        raise(ArgumentError, "Only 2 credentials are allowed: #{login_field} and #{password_field}") if !values.is_a?(Hash) || values.keys.size > 2 || !values.key?(login_field) || !values.key?(password_field)
        values.each { |field, value| send("#{field}=", value) }
      end
      
      # Resets everything, your errors, record, cookies, and session. Basically "logs out" a user.
      def destroy
        errors.clear
        @record = nil
        cookies.delete cookie_key
        session[session_key] = nil
      end
      
      # Errors when authentication fails, just like ActiveRecord errors. In fact it uses the same exact class.
      def errors
        @errors ||= Errors.new(self)
      end
      
      def inspect # :nodoc:
        details = {}
        case login_with
        when :unauthorized_record
          details[:unauthorized_record] = unauthorized_record
        else
          details[login_field.to_sym] = send(login_field)
          details[password_field.to_sym] = "<protected>"
        end
        "#<#{self.class.name} #{details.inspect}>"
      end
      
      # Allows users to be remembered via a cookie.
      def remember_me?
        remember_me == true || remember_me = "true" || remember_me == "1"
      end
      
      # When to expire the cookie. See remember_me_for configuration option to change this.
      def remember_me_until
        remember_me_for.from_now
      end
      
      # Sometimes you don't want to create a session via credentials (login and password). Maybe you already have the record. Just set this record to this and it will be authenticated when you try to validate
      # the session. Basically this is another form of credentials, you are just skipping username and password validation.
      def unauthorized_record=(value)
        self.login_with = :unauthorized_record
        @unauthorized_record = value
      end
      
      # Updates the session with any new information. Resets the session and cookie.
      def update
        create(true)
      end
      
      # Same as update but raises an exception if validation is failed
      def update!
        create!(true)
      end
      
      def valid?(set_session = false)
        errors.clear
        temp_record = unauthorized_record
        
        if login_with == :credentials
          errors.add(login_field, "can not be blank") if login.blank?
          errors.add(password_field, "can not be blank") if protected_password.blank?
          return false if errors.count > 0

          temp_record = klass.send(find_by_login_method, send(login_field))

          if temp_record.blank?
            errors.add(login_field, "was not found")
            return false
          end
          
          unless temp_record.send(verify_password_method, protected_password)
            errors.add(password_field, "is invalid")
            return false
          end
        end

        [:approved, :confirmed, :inactive].each do |required_status|
          if temp_record.respond_to?("#{required_status}?") && !temp_record.send("#{required_status}?") 
            errors.add_to_base("Your account has not been #{required_status}")       
            return false
          end
        end
        
        # All is good, lets set the record
        @record = temp_record
        
        # Now lets set the session to make things easier on successive requests. This is nice when logging in from a cookie, the next requests will be right from the session, which is quicker.
        if set_session
          session[session_key] = record.id
          if record.class.column_names.include?("last_click_at")
            record.last_click_at = Time.now
            record.saving_from_session = true
            record.save(false)
          end
        end
        
        true
      end
      
      def valid_http_auth?(set_session = false)
        controller.authenticate_with_http_basic do |login, password|
          if !login.blank? && !password.blank?
            send("#{login_method}=", login)
            send("#{password_method}=", password)
            return valid?(set_session)
          end
        end
        
        false
      end
      
      def valid_cookie?(set_session = false)
        if cookie_credentials
          self.unauthorized_record = klass.send("find_by_#{remember_token_field}", cookie_credentials)
          valid?(set_session)
        end
        
        false
      end
      
      def valid_session?
        if session_credentials
          self.unauthorized_record = klass.find_by_id(session_credentials)
          return valid?
        end
        
        false
      end
      
      private
        def controller
          self.class.controller
        end
        
        def cookies
          controller.send(:cookies)
        end
        
        def cookie_credentials
          cookies[cookie_key]
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
          end_eval
        end
        
        def klass
          self.class.klass
        end
      
        def klass_name
          self.class.klass_name
        end
        
        # The password should not be accessible publicly. This way forms using form_for don't fill the password with the attempted password. The prevent this we just create this method that is private.
        def protected_password
          @password
        end
        
        def session
          controller.session
        end
        
        def session_credentials
          session[session_key]
        end
    end
  end
end