module Authlogic
  module Session
    # = Session
    #
    # Handles all parts of authentication that deal with sessions. Such as persisting a session and saving / destroy a session.
    module OpenID
      def self.included(klass)
        klass.class_eval do
          attr_accessor :
          alias_method_chain :credentials=, :openid
        end
      end
      
      # Tries to validate the session from information in the session
      def credentials_with_openid=(value)
        self.credentials_without_openid
      end