module Authlogic
  module ShouldaMacros
    class Test::Unit::TestCase
      def self.should_be_authentic
        klass = model_class
        should "acts as authentic" do
          assert klass.respond_to?(:acts_as_authentic_config)
        end
      end
    end
  end
end