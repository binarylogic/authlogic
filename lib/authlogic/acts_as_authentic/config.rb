module Authlogic
  module ActsAsAuthentic
    class Config # :nodoc:
      include Email::Config
      include LoggedInStatus::Config
      include Login::Config
      include Password::Config
      include PerishableToken::Config
      include RestfulAuthentication::Config
      include Scope::Config
      include SessionMaintenance::Config
      include SingleAccessToken::Config
      
      attr_accessor :klass
      
      def initialize(klass)
        self.klass = klass
      end
      
      private
        def config(key, value, default_value = nil, read_value = nil)
          if value == read_value
            v = instance_variable_defined?("@#{key}") ? instance_variable_get("@#{key}") : nil
            return v if !v.nil?
            instance_variable_set("@#{key}", default_value)
          else
            instance_variable_set("@#{key}", value)
          end
        end
        
        def first_column_to_exist(*columns_to_check) # :nodoc:
          columns_to_check.each { |column_name| return column_name.to_sym if klass.column_names.include?(column_name.to_s) }
          columns_to_check.first ? columns_to_check.first.to_sym : nil
        end
    end
  end
end