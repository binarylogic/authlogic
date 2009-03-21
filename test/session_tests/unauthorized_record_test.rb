require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class UnauthorizedRecordTest < ActiveSupport::TestCase
    def test_save_with_record
      ben = users(:ben)
      session = UserSession.new(ben)
      assert session.save
      assert !session.new_session?
    end
  end
end