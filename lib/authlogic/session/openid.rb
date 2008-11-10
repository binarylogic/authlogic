module Authlogic
  module Session
    module OpenID
      def self.included(klass)
        klass.alias_method_chain :create_configurable_methods!, :openid
        klass.before_validation :valid_openid?
        klass.attr_accessor :openid_response
      end
      
      # Returns true if logging in with openid. Credentials mean username and password.
      def logging_in_with_openid?
        login_with == :openid
      end
      
      def valid_openid?
        if controller.params[:openid_complete].blank?
          if send(openid_field).blank?
            errors.add(openid_field, "can not be blank")
            return false
          end
          
          begin
            self.openid_response = openid_consumer.begin(send(openid_field))
          rescue OpenID::OpenIDError => e
            errors.add("The OpenID identifier #{send(openid_field)} could not be found: #{e}")
            return false
          end
          
          sregreq = OpenID::SReg::Request.new
          # required fields
          #sregreq.request_fields(['email','nickname'], true)
          # optional fields
          #sregreq.request_fields(['dob', 'fullname'], false)
          oidreq.add_extension(sregreq)
          oidreq.return_to_args["openid_complete"] = 1
        else
          case openid_response.status
          when OpenID::Consumer::SUCCESS
            
          when OpenID::Consumer::CANCEL
            errors.add_to_base("OpenID authentication was cancelled.")
          when OpenID::Consumer::FAILURE
            errors.add_to_base("OpenID authentication failed.")
          when OpenID::Consumer::SETUP_NEEDED
            errors.add_to_Base("OpenID authentication needs setup.")
          end
        end
      end
      
      private
        def create_configurable_methods_with_openid!
          create_configurable_methods_without_openid!
          
          return if respond_to?(openid_field)
          
          if openid_field
            self.class.class_eval <<-"end_eval", __FILE__, __LINE__
              attr_reader :#{openid_field}
              
              def #{openid_field}=(value)
                self.login_with = :openid
                @#{openid_field} = value
              end
            end_eval
          end
        end
        
        def openid_consumer
          @openid_consumer ||= OpenID::Consumer.new(controller.session, OpenID::FilesystemStore.new(openid_file_store_path))
        end
    end
  end
end