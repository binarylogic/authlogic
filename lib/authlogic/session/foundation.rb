module Authlogic
  module Session
    # Sort of like an interface, it sets the foundation for the class, such as the required methods. This also allows
    # other modules to overwrite methods and call super on them. It's also a place to put "utility" methods used
    # throughout Authlogic.
    module Foundation
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end
      
      module ClassMethods
        private
          def rw_config(key, value, default_value = nil, read_value = nil)
            if value == read_value
              return read_inheritable_attribute(key) if inheritable_attributes.include?(key)
              write_inheritable_attribute(key, default_value)
            else
              write_inheritable_attribute(key, value)
            end
          end
      end
      
      module InstanceMethods
        def initialize(*args)
          self.credentials = args
        end
        
        # The credentials you passed to create your session. See credentials= for more info.
        def credentials
          []
        end

        # Set your credentials before you save your session. You can pass a hash of credentials:
        #
        #   session.credentials = {:login => "my login", :password => "my password", :remember_me => true}
        #
        # or you can pass an array of objects:
        #
        #   session.credentials = [my_user_object, true]
        #
        # and if you need to set an id, just pass it last. This value need be the last item in the array you pass, since the id is something that
        # you control yourself, it should never be set from a hash or a form. Examples:
        #
        #   session.credentials = [{:login => "my login", :password => "my password", :remember_me => true}, :my_id]
        #   session.credentials = [my_user_object, true, :my_id]
        def credentials=(values)
        end
        
        def inspect
          "#<#{self.class.name}: #{credentials.blank? ? "no credentials provided" : credentials.inspect}>"
        end
        
        private
          def build_key(last_part)
            last_part
          end
      end
    end
  end
end