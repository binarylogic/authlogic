require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class ActiveRecordTrickeryTest < ActiveSupport::TestCase
    def test_human_attribute_name
      assert_equal "Some attribute", UserSession.human_attribute_name("some_attribute")
    end
  
    def test_new_record
      session = UserSession.new
      assert session.new_record?
    end
  end
end