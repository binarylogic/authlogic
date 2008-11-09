require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class ScopesTest < ActiveSupport::TestCase
    def test_scope
      UserSession.with_scope(:find_options => {:conditions => "awesome = 1"}, :id => "some_id") do
        assert_equal({:find_options => {:conditions => "awesome = 1"}, :id => "some_id"}, UserSession.scope)
      end
      assert_nil UserSession.scope
    end
  
    def test_with_scope
      assert_raise(ArgumentError) { UserSession.with_scope }
      # the rest of the method was tested in test_scope
    end
  
    def test_initialize
      
    end
  end
end