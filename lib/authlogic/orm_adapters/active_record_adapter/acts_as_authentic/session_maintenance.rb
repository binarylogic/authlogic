module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Session Maintenance
        #
        # Responsible for maintaining the related session as the record changes. Here is what it does:
        #
        # 1. If the user is logged out and creates a new record, they will be logged in as that record
        # 2. If the user is logged out and changes a record's password, they will be logged in as that record
        # 3. If a user is logged in and changes his own password, their session will be updated accordingly. This can be done *anywhere*: the my account section, admin area, etc.
        #
        # === Instance Methods
        #
        # * <tt>save_without_session_maintenance</tt> - allows you to save the record and skip all of the session maintenance completely
        module SessionMaintenance
          def acts_as_authentic_with_session_maintenance(options = {})
            acts_as_authentic_without_session_maintenance(options)
            
            before_save :get_session_information, :if => :update_sessions?
            before_save :maintain_sessions, :if => :update_sessions?
            
            class_eval <<-"end_eval", __FILE__, __LINE__
              def save_without_session_maintenance(*args)
                @skip_session_maintenance = true
                result = save(*args)
                @skip_session_maintenance = false
                result
              end
              
              protected
                def update_sessions?
                  !@skip_session_maintenance && #{options[:session_class]}.activated? && !#{options[:session_ids].inspect}.blank? && #{options[:persistence_token_field]}_changed?
                end
                
                def get_session_information
                  # Need to determine if we are completely logged out, or logged in as another user
                  @_sessions = []
                  
                  #{options[:session_ids].inspect}.each do |session_id|
                    session = #{options[:session_class]}.find(session_id, self)
                    @_sessions << session if session && session.record
                  end
                end
                
                def maintain_sessions
                  if @_sessions.empty?
                    create_session
                  else
                    update_sessions
                  end
                end
                
                def create_session
                  # We only want to automatically login into the first session, since this is the main session. The other sessions are sessions
                  # that need to be created after logging into the main session.
                  session_id = #{options[:session_ids].inspect}.first
                  #{options[:session_class]}.create(*[self, self, session_id].compact)

                  return true
                end
                
                def update_sessions
                  # We found sessions above, let's update them with the new info
                  @_sessions.each do |stale_session|
                    next if stale_session.record != self
                    stale_session.unauthorized_record = self
                    stale_session.save
                  end

                  return true
                end
            end_eval
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::SessionMaintenance
    alias_method_chain :acts_as_authentic, :session_maintenance
  end
end