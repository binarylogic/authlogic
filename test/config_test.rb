require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  def setup
    @klass = Class.new {
      extend Authlogic::Config

      def self.foobar(value = nil)
        rw_config(:foobar_field, value, 'default_foobar')
      end
    }

    @subklass = Class.new(@klass)
  end

  def test_config
    assert_equal({}, @klass.acts_as_authentic_config)
  end

  def test_rw_config_read_with_default
    assert 'default_foobar', @klass.foobar
  end

  def test_rw_config_write
    assert_equal 'my_foobar', @klass.foobar('my_foobar')
    assert_equal 'my_foobar', @klass.foobar

    assert_equal 'my_new_foobar', @klass.foobar('my_new_foobar')
    assert_equal 'my_new_foobar', @klass.foobar
  end

  def test_subclass_rw_config_write
    assert_equal 'subklass_foobar', @subklass.foobar('subklass_foobar')
    assert_equal 'default_foobar', @klass.foobar
  end
end
