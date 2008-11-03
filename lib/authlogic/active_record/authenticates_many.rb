module Authlogic
  module ActiveRecord
    module AuthenticatesMany
      def authenticates_many(name, options = {})
        options[:session_class] ||= name.to_s.classify.constantize
        options[:relationship_name] ||= options[:session_class].klass_name.underscore.pluralize
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{name}
            find_options = #{options[:find_options].inspect} || #{options[:relationship_name]}.scope(:find)
            find_options.delete_if { |key, value| ![:conditions, :include, :joins].include?(key.to_sym) || value.nil? }
            @#{name} ||= Authlogic::ActiveRecord::ScopedSession.new(#{options[:session_class]}, find_options, #{options[:scope_cookies] ? "self.class.model_name.underscore + '_' + self.send(self.class.primary_key).to_s" : "nil"})
          end
        end_eval
      end
    end
  end
end

ActiveRecord::Base.extend Authlogic::ActiveRecord::AuthenticatesMany