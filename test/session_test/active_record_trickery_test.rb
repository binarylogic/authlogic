require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTest
  module ActiveRecordTrickeryTest
    class ClassMethodsTest < ActiveSupport::TestCase
      def test_human_attribute_name
        assert_equal "Some attribute", UserSession.human_attribute_name("some_attribute")
        assert_equal "Some attribute", UserSession.human_attribute_name(:some_attribute)
      end
    
      def test_human_name
        assert_equal "Usersession", UserSession.human_name
      end
    
      def test_self_and_descendents_from_active_record
        assert_equal [UserSession], UserSession.self_and_descendents_from_active_record
      end
    
      def test_self_and_descendants_from_active_record
        assert_equal [UserSession], UserSession.self_and_descendants_from_active_record
      end
    end
    
    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_new_record
        session = UserSession.new
        assert session.new_record?
      end
      
      def test_to_model
        session = UserSession.new
        assert session, session.to_model
      end
    end
  end
end
