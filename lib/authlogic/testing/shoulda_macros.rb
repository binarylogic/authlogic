require "test/unit"

module Authlogic
  module Testing
    module ShouldaMacros
      def should_be_authentic(model)
        should "acts as authentic" do
          assert model.respond_to?(:unique_token)
          assert model.respond_to?(:forget_all!)
          assert model.respond_to?(:crypto_provider)
        end
      end
    end
  end
end

Test::Unit::TestCase.extend Authlogic::Testing::ShouldaMacros