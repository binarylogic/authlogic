# Place this file into your spec/support/matchers directory
#
# Example:
#
# describe User do
#   it { should have_authlogic }
# end

module Authlogic
  module RspecMatchers
    def have_authlogic
      HaveAuthlogic.new
    end
  
    class HaveAuthlogic
    
      def matches?(subject)
        subject.respond_to?(:password=) && subject.respond_to?(:valid_password?)
      end
    
      def failure_message
        "Add the line 'acts_as_authentic' to your model"
      end
    
      def description
        "have Authlogic"
      end
    end
  end
  
end

if defined?(Spec)
  Spec::Runner.configure do |config|
    config.include(Authlogic::RspecMatchers)
  end
end
