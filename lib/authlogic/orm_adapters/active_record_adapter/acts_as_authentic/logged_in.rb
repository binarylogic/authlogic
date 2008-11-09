module Authlogic
  module ORMAdapters
    module ActiveRecordAdapter
      module LoggedIn # :nodoc:
        def acts_as_authentic_with_logged_in(options = {})
          acts_as_authentic_without_logged_in(options)
          
          options[:logged_in_timeout] ||= 10.minutes
          
          validates_numericality_of :login_count, :only_integer => :true, :greater_than_or_equal_to => 0, :allow_nil => true if column_names.include?("login_count")
      
          if column_names.include?("last_request_at")
            named_scope :logged_in, lambda { {:conditions => ["last_request_at > ?", options[:logged_in_timeout].ago]} }
            named_scope :logged_out, lambda { {:conditions => ["last_request_at is NULL or last_request_at <= ?", options[:logged_in_timeout].ago]} }
          end
          
          class_eval <<-"end_eval", __FILE__, __LINE__
            def self.logged_in_timeout
              #{options[:logged_in_timeout].to_i}.seconds
            end
          end_eval
      
          if column_names.include?("last_request_at")
            class_eval <<-"end_eval", __FILE__, __LINE__
              def logged_in?
                !last_request_at.nil? && last_request_at > self.class.logged_in_timeout.ago
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
    include Authlogic::ORMAdapters::ActiveRecordAdapter::LoggedIn
    alias_method_chain :acts_as_authentic, :logged_in
  end
end