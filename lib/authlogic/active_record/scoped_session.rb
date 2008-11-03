module Authlogic
  module ActiveRecord
    class ScopedSession # :nodoc:
      attr_accessor :klass, :find_options, :id
      
      def initialize(klass, find_options, id)
        self.klass = klass
        self.find_options = find_options
        self.id = id
      end
      
      [:create, :create!, :find, :new].each do |method|
        class_eval <<-"end_eval", __FILE__, __LINE__
          def #{method}(*args)
            klass.with_scope(scope_options) do
              klass.#{method}(*args)
            end
          end
        end_eval
      end
      
      private
        def scope_options
          {:find_options => find_options, :id => id}
        end
    end
  end
end