require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTest
  class IdTest < ActiveSupport::TestCase
    def test_credentials
      session = UserSession.new
      session.credentials = [:my_id]
      assert_equal :my_id, session.id
    end
      
    def test_id
      session = UserSession.new
      session.id = :my_id
      assert_equal :my_id, session.id
    end
  end
end