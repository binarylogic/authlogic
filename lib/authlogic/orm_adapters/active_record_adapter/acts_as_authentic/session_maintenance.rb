module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module SessionMaintenance # :nodoc:
        def acts_as_authentic_with_session_maintenance(options = {})
          acts_as_authentic_without_session_maintenance(options)
          
          options[:session_class] ||= "#{name}Session"
          options[:session_ids] ||= [nil]
          
          before_save :get_session_information, :if => :update_sessions?
          after_save :maintain_sessions!, :if => :update_sessions?
          
          class_eval <<-"end_eval", __FILE__, __LINE__
            def save_without_session_maintenance(*args)
              @skip_session_maintenance = true
              result = save(*args)
              @skip_session_maintenance = false
              result
            end
            
            protected
              def update_sessions?
                !@skip_session_maintenance && #{options[:session_class]}.activated? && !#{options[:session_ids].inspect}.blank? && #{remember_token_field}_changed?
              end
            
              def get_session_information
                # Need to determine if we are completely logged out, or logged in as another user
                @_sessions = []
                @_logged_out = true
          
                #{options[:session_ids].inspect}.each do |session_id|
                  session = #{options[:session_class]}.find(*[session_id].compact)
                  if session
                    if !session.record.blank?
                      @_logged_out = false
                      @_sessions << session if session.record == self
                    end
                  end
                end
              end
        
              def maintain_sessions!
                if @_logged_out
                  create_session!
                elsif !@_sessions.blank?
                  update_sessions!
                end
              end
        
              def create_session!
                # We only want to automatically login into the first session, since this is the main session. The other sessions are sessions
                # that need to be created after logging into the main session.
                session_id = #{options[:session_ids].inspect}.first
          
                # If we are already logged in, ignore this completely. All that we care about is updating ourself.
                next if #{options[:session_class]}.find(*[session_id].compact)
                        
                # Log me in
                args = [self, session_id].compact
                #{options[:session_class]}.create(*args)
              end
        
              def update_sessions!
                # We found sessions above, let's update them with the new info
                @_sessions.each do |stale_session|
                  stale_session.unauthorized_record = self
                  stale_session.save
                end
              end
          end_eval
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::SessionMaintenance
    alias_method_chain :acts_as_authentic, :session_maintenance
  end
end