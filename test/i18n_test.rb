require File.dirname(__FILE__) + '/test_helper.rb'

class I18nTest < ActiveSupport::TestCase
  def test_uses_authlogic_as_scope_by_default
    assert_equal :authlogic, Authlogic::I18n.scope
  end
  
  def test_can_set_scope
    assert_nothing_raised{ Authlogic::I18n.scope = [:a, :b] }
    assert_equal [:a, :b], Authlogic::I18n.scope
    Authlogic::I18n.scope = :authlogic
  end
end
