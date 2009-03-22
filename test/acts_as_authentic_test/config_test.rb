require File.dirname(__FILE__) + '/../test_helper.rb'

module ActsAsAuthenticTest
  class ConfigTest < ActiveSupport::TestCase
    def test_initialize
      c = Authlogic::ActsAsAuthentic::Config.new(User)
      assert_equal c.klass, User
    end
  end
end