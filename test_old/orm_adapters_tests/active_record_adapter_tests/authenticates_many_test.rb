require File.dirname(__FILE__) + '/../../test_helper.rb'

module ORMAdaptersTests
  module ActiveRecordAdapterTests
    class AuthenticatesManyTest < ActiveSupport::TestCase
      def test_authenticates_many_new
        binary_logic = companies(:binary_logic)
        user_session = binary_logic.user_sessions.new
        assert_equal({:find_options => {:conditions => "\"users\".company_id = #{binary_logic.id}"}, :id => nil}, user_session.scope)
    
        employee_session = binary_logic.employee_sessions.new
        assert_equal({:find_options => {:conditions => "\"employees\".company_id = #{binary_logic.id}"}, :id => nil}, employee_session.scope)
      end
  
      def test_authenticates_many_create_and_find
        binary_logic = companies(:binary_logic)
        logic_over_data = companies(:logic_over_data)
        ben = users(:ben)
        zack = users(:zack)
    
        assert !binary_logic.user_sessions.find
        assert !logic_over_data.user_sessions.find
        assert logic_over_data.user_sessions.create(zack)
        assert !binary_logic.user_sessions.find
        assert logic_over_data.user_sessions.find
        assert binary_logic.user_sessions.create(ben)
        assert binary_logic.user_sessions.find
        assert !logic_over_data.user_sessions.find
      end
    end
  end
end