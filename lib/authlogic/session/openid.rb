module Authlogic
  module Session
    module OpenID
      def self.included(klass)
        klass.class_eval do
          alias_method_chain :initialize, :openid
          alias_method_chain :credentials=, :openid
          alias_method_chain :create_configurable_methods!, :openid
          before_validation :valid_openid?
          attr_accessor :openid_response
        end
      end
      
      def initialize_with_openid(*args)
        initialize_without_openid(*args)
        self.authenticating_with = :openid if openid_verification_complete?
      end
      
      def credentials_with_openid=(values)
        result = self.credentials_without_openid = values
        return result if openid_field.blank? || values.blank? || !values.is_a?(Hash) || values[:openid].blank?
        self.openid = values[:openid]
        result
      end
      
      # Returns true if logging in with openid. Credentials mean username and password.
      def authenticating_with_openid?
        authenticating_with == :openid
      end
      
      def verify_openid?
        authenticating_with_openid? && controller.params[:openid_complete] != "1"
      end
      
      def openid_verified?
        controller.params[:openid_complete] == "1"
      end
      
      def valid_openid?
        return false if openid_field.blank?
        
        if openid_verification_complete?
          case openid_response.status
          when OpenID::Consumer::SUCCESS
            
          when OpenID::Consumer::CANCEL
            errors.add_to_base("OpenID authentication was cancelled.")
          when OpenID::Consumer::FAILURE
            errors.add_to_base("OpenID authentication failed.")
          when OpenID::Consumer::SETUP_NEEDED
            errors.add_to_Base("OpenID authentication needs setup.")
          end
        else
          if authenticating_with_openid?
            if send(openid_field).blank?
              errors.add(openid_field, "can not be blank")
              return false
            end
            
            unless search_for_record(find_by_openid_method, send(openid_field))
              errors.add(openid_field, "did not match any records in our database")
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
          end
        end
      end
      
      private
        def create_configurable_methods_with_openid!
          create_configurable_methods_without_openid!
          
          return if openid_field.blank? || respond_to?(openid_field)
          
          if openid_field
            self.class.class_eval <<-"end_eval", __FILE__, __LINE__
              attr_reader :#{openid_field}
              
              def #{openid_field}=(value)
                self.authenticating_with = :openid
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