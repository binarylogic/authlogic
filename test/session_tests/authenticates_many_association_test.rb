require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class AuthenticatesManyAssociationTest < ActiveSupport::TestCase
    def test_initialize
      assoc = Authlogic::Session::AuthenticatesManyAssociation.new(UserSession, {:conditions => ["1 = ?", 1]}, :some_id)
      assert_equal UserSession, assoc.klass
      assert_equal({:conditions => ["1 = ?", 1]}, assoc.find_options)
      assert_equal :some_id, assoc.id
    end
    
    def test_new
      ben = users(:ben)
      assoc = Authlogic::Session::AuthenticatesManyAssociation.new(UserSession, {:conditions => ["1 = ?", 1]}, :some_id)
      session = assoc.new(ben)
      assert_equal ben, session.unauthorized_record
      assert_equal({:find_options => {:conditions => ["1 = ?", 1]}, :id => :some_id}, session.scope)
    end
  end
end