module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module ActsAsAuthentic
        # = Logged In
        #
        # Handles all logic determining if a record is logged in or not. This uses the "last_request_at" field, if this field is not present none of this will be available.
        #
        # === Named Scopes
        #
        # * <tt>logged_in</tt> - returns all records that have a last_request_at value that is > your :logged_in_timeout.ago
        # * <tt>logged_out</tt> - same as logged in but returns users that are logged out, be careful with using this, this can return a lot of users
        #
        # === Instance Methods
        #
        # * <tt>logged_in?</tt> - same as the logged_in named scope, but returns true if the record is logged in
        # * <tt>logged_out?</tt> - opposite of logged_in?
        module LoggedIn
          def acts_as_authentic_with_logged_in(options = {})
            acts_as_authentic_without_logged_in(options)
            
            validates_numericality_of :login_count, :only_integer => :true, :greater_than_or_equal_to => 0, :allow_nil => true if column_names.include?("login_count")
            
            if column_names.include?("last_request_at")
              class_eval <<-"end_eval", __FILE__, __LINE__
                named_scope :logged_in, lambda { {:conditions => ["last_request_at > ?", #{options[:logged_in_timeout]}.seconds.ago]} }
                named_scope :logged_out, lambda { {:conditions => ["last_request_at is NULL or last_request_at <= ?", #{options[:logged_in_timeout]}.seconds.ago]} }
                
                def logged_in?
                  raise "Can not determine the records login state because there is no last_request_at column" if !respond_to?(:last_request_at)
                  !last_request_at.nil? && last_request_at > #{options[:logged_in_timeout]}.seconds.ago
                end
              
                def logged_out?
                  !logged_in?
                end
              end_eval
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  class << self
    include Authlogic::ORMAdapters::ActiveRecordAdapter::ActsAsAuthentic::LoggedIn
    alias_method_chain :acts_as_authentic, :logged_in
  end
end