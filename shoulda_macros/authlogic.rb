require "test/unit"

module Authlogic
  module ShouldaMacros
    def should_be_authentic
      klass = model_class
      should "acts as authentic" do
        assert klass.respond_to?(:acts_as_authentic_config)
      end
    end
  end
end

Test::Unit::TestCase.extend Authlogic::ShouldaMacros