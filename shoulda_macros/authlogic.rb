require "test/unit"

module Authlogic
  module ShouldaMacros
    def should_be_authentic(model)
      should "acts as authentic" do
        assert model.respond_to?(:acts_as_authentic_config)
      end
    end
  end
end

Test::Unit::TestCase.extend Authlogic::ShouldaMacros