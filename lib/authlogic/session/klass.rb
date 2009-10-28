module Authlogic
  module Session
    # Handles authenticating via a traditional username and password.
    module Klass
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
          
          class << self
            attr_accessor :configured_klass_methods
          end
        end
      end
      
      module Config
        # Lets you change which model to use for authentication.
        #
        # * <tt>Default:</tt> inferred from the class name. UserSession would automatically try User
        # * <tt>Accepts:</tt> an ActiveRecord class
        def authenticate_with(klass)
          @klass_name = klass.name
          @klass = klass
        end
        alias_method :authenticate_with=, :authenticate_with
        
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
          @klass_name ||= guessed_klass_name
        end
        
        # The string of the model name class guessed from the actual session class name.
        def guessed_klass_name
          guessed_name = name.scan(/(.*)Session/)[0]
          guessed_name[0] if guessed_name
        end
      end
      
      module InstanceMethods
        # Creating an alias method for the "record" method based on the klass name, so that we can do:
        #
        #   session.user
        #
        # instead of:
        #
        #   session.record
        def initialize(*args)
          if !self.class.configured_klass_methods
            self.class.send(:alias_method, klass_name.demodulize.underscore.to_sym, :record)
            self.class.configured_klass_methods = true
          end
          super
        end
        
        private
          def klass
            self.class.klass
          end

          def klass_name
            self.class.klass_name
          end
      end
    end
  end
end