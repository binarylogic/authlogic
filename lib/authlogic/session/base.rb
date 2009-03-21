module Authlogic
  module Session # :nodoc:
    # = Base
    #
    # This is the base class Authlogic, it defined the pattern and sets the "base". For more information see the methods
    # below.
    class Base
      include ActiveRecordTrickery
      include Callbacks
      
      # Included first so that the session resets itself to nil
      include Timeout
      
      # Included in a specific order so they are tried in this order when persisting
      include Params
      include Cookies
      include Session
      include HttpAuth
      
      # Included in a specific order so magic states gets ran after a record is found
      include Password
      include UnauthorizedRecord
      include MagicStates
      
      include BruteForceProtection
      include MagicColumns
      include PerishableToken
      include Scopes
      
      class << self
        attr_accessor :methods_configured
        
        # Lets you change which model to use for authentication.
        #
        # * <tt>Default:</tt> inferred from the class name. UserSession would automatically try User
        # * <tt>Accepts:</tt> an ActiveRecord class
        def authenticate_with(klass)
          @klass_name = klass.name
          @klass = klass
        end
        alias_method :authenticate_with=, :authenticate_with
        
        # Returns true if a controller has been set and can be used properly. This MUST be set before anything can be done.
        # Similar to how ActiveRecord won't allow you to do anything without establishing a DB connection. In your framework
        # environment this is done for you, but if you are using Authlogic outside of your framework, you need to assign a controller
        # object to Authlogic via Authlogic::Session::Base.controller = obj. See the controller= method for more information.
        def activated?
          !controller.nil?
        end
        
        # This accepts a controller object wrapped with the Authlogic controller adapter. The controller adapters close the gap
        # between the different controllers in each framework. That being said, Authlogic is expecting your object's class to
        # extend Authlogic::ControllerAdapters::AbstractAdapter. See Authlogic::ControllerAdapters for more info.
        def controller=(value)
          Thread.current[:authlogic_controller] = value
        end
        
        # The current controller object
        def controller
          Thread.current[:authlogic_controller]
        end
        
        # A convenince method. The same as:
        #
        #   session = UserSession.new(*args)
        #   session.create
        #
        # Instead you can do:
        #
        #   UserSession.create(*args)
        def create(*args, &block)
          session = new(*args)
          session.save(&block)
        end
        
        # Same as create but calls create!, which raises an exception when validation fails.
        def create!(*args)
          session = new(*args)
          session.save!
        end
        
        # This is how you persist a session. This finds the record for the current session using
        # a variety of methods. It basically tries to "log in" the user without the user having
        # to explicitly log in. Check out the other Authlogic::Session modules for more information.
        #
        # The best way to use this method is something like:
        #
        #   helper_method :current_user_session, :current_user
        #
        #   def current_user_session
        #     return @current_user_session if defined?(@current_user_session)
        #     @current_user_session = UserSession.find
        #   end
        #
        #   def current_user
        #     return @current_user if defined?(@current_user)
        #     @current_user = current_user_session && current_user_session.user
        #   end
        #
        # Also, this method accepts a single parameter as the id, to find session that you marked with an id:
        #
        #   UserSession.find(:secure)
        #
        # See the id method for more information on ids.
        def find(id = nil, priority_record = nil)
          session = new(id)
          session.priority_record = priority_record
          if session.persisting?
            session
          else
            nil
          end
        end
        
        # The name of the class that this session is authenticating with. For example, the UserSession class will
        # authenticate with the User class unless you specify otherwise in your configuration. See authenticate_with
        # for information on how to change this value.
        def klass
          @klass ||=
            if klass_name
              klass_name.constantize
            else
              nil
            end
        end
        
        # Same as klass, just returns a string instead of the actual constant.
        def klass_name
          @klass_name ||= 
            if guessed_name = name.scan(/(.*)Session/)[0]
              @klass_name = guessed_name[0]
            end
        end
        
        private
          def config(key, value, default_value = nil, read_value = nil)
            if value == read_value
              return read_inheritable_attribute(key) if inheritable_attributes.include?(key)
              write_inheritable_attribute(key, default_value)
            else
              write_inheritable_attribute(key, value)
            end
          end
      end
      
      attr_accessor :new_session, :priority_record, :record
      attr_reader :attempted_record
      attr_writer :id
    
      # You can initialize a session by doing any of the following:
      #
      #   UserSession.new
      #   UserSession.new(:login => "login", :password => "password", :remember_me => true)
      #   UserSession.new(User.first, true)
      #
      # If a user has more than one session you need to pass an id so that Authlogic knows how to differentiate the
      # sessions. The id MUST be a Symbol.
      #
      #   UserSession.new(:my_id)
      #   UserSession.new({:login => "login", :password => "password", :remember_me => true}, :my_id)
      #   UserSession.new(User.first, true, :my_id)
      #
      # For more information on ids see the id method.
      #
      # Lastly, the reason the id is separate from the first parameter hash is becuase this should be controlled by you,
      # not by what the user passes. A user could inject their own id and things would not work as expected.
      def initialize(*args)
        raise NotActivated.new(self) unless self.class.activated?
        
        before_initialize
        
        if !self.class.methods_configured
          self.class.send(:alias_method, klass_name.demodulize.underscore.to_sym, :record)
          self.class.methods_configured = true
        end
        
        self.id = args.pop if args.last.is_a?(Symbol)
        
        if args.size == 1 && args.first.is_a?(Hash)
          self.credentials = args.first
        elsif !args.first.blank? && args.first.class < ::ActiveRecord::Base
          self.unauthorized_record = args.shift
          self.priority_record = args.shift if args.first.class < ::ActiveRecord::Base
          self.remember_me = args.shift if !args.empty?
        end
        
        after_initialize
      end
      
      # Clears all errors and the associated record, you should call this terminate a session, thus requring
      # the user to authenticate again if it is needed.
      def destroy
        before_destroy
        errors.clear
        @record = nil
        after_destroy
        true
      end
      
      # The errors in Authlogic work JUST LIKE ActiveRecord. In fact, it uses the exact same ActiveRecord errors class.
      # Use it the same way:
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
      
      # Let's you know if the session is being persisted or not, meaning the user does not have to explicitly log in
      # in order to be logged in. If the session has no associated record, it will try to find a record and persis
      # the session. This is the method that the class level method find uses to ultimately persist the session.
      def persisting?
        return true if !record.nil?
        self.attempted_record = nil
        before_persisting
        persist
        ensure_authentication_attempted
        if errors.empty? && !attempted_record.nil?
          self.record = attempted_record
          after_persisting
          save_record
          self.new_session = false
          true
        else
          false
        end
      end
      
      # Allows you to set a unique identifier for your session, so that you can have more than 1 session at a time.
      # A good example when this might be needed is when you want to have a normal user session and a "secure" user session.
      # The secure user session would be created only when they want to modify their billing information, or other sensitive
      # information. Similar to me.com. This requires 2 user sessions. Just use an id for the "secure" session and you should be good.
      #
      # You can set the id during initialization (see initialize for more information), or as an attribute:
      #
      #   session.id = :my_id
      #
      # Just be sure and set your id before you save your session.
      #
      # Lastly, to retrieve your session with the id check out the find class method.
      def id
        @id
      end
      
      # Custom inspect method for the object for security reasons and to make IRB useful.
      def inspect
        "#<#{self.class.name}>"
      end
      
      # Returns true if the session has not been saved yet.
      def new_session?
        new_session != false
      end
      
      # After you have specified all of the details for your session you can try to save it. This will
      # run validation checks and find the associated record, if all validation passes. If validation
      # does not pass, the save will fail and the erorrs will be stored in the errors object.
      def save(&block)
        result = nil
        if valid?
          self.record = attempted_record

          before_save
          new_session? ? before_create : before_update
          new_session? ? after_create : after_update
          after_save
          
          save_record
          self.new_session = false
          result = true
        else
          result = false
        end
        
        yield result if block_given?
        result
      end
      
      # Same as save but raises an exception of validation errors when validation fails
      def save!
        result = save
        raise SessionInvalid.new(self) unless result
        result
      end
      
      # Determines if the information you provided for authentication is valid or not. If there is
      # a problem with the information provided errors will be added to the errors object and this
      # method will return false.
      def valid?
        errors.clear
        self.attempted_record = nil
        
        before_validation
        new_session? ? before_validation_on_create : before_validation_on_update
        validate
        ensure_authentication_attempted
                
        if errors.empty?
          new_session? ? after_validation_on_create : after_validation_on_update
          after_validation
        end
        
        save_record(attempted_record)
        errors.empty?
      end
      
      private
        def attempted_record=(value)
          @attempted_record = value == priority_record ? priority_record : value
        end
        
        def controller
          self.class.controller
        end
        
        def ensure_authentication_attempted
          errors.add_to_base(I18n.t('error_messages.no_authentication_attempted', :default => "No authentication method was attempted.")) if errors.empty? && attempted_record.nil?
        end
        
        def klass
          self.class.klass
        end
      
        def klass_name
          self.class.klass_name
        end
        
        def save_record(alternate_record = nil) # :nodoc:
          r = alternate_record || record
          r.save_without_session_maintenance(false) if r && r != priority_record && r.changed?
        end
    end
  end
end