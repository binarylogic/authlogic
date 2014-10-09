require 'test_helper'

module SessionTest
  module SessionTest
    class ConfigTest < ActiveSupport::TestCase
      def test_disable_magic_states_config
        klass = testable_user_session_class

        klass.disable_magic_states = true
        assert_equal true, klass.disable_magic_states

        klass.disable_magic_states false
        assert_equal false, klass.disable_magic_states
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_disabling_magic_states
        klass = testable_user_session_class

        klass.disable_magic_states = true

        ben = users(:ben)
        ben.update_attribute(:active, false)
        assert klass.create(ben)
      end

      def test_validate_validate_magic_states_active
        session = UserSession.new
        ben = users(:ben)
        session.unauthorized_record = ben
        assert session.valid?

        ben.update_attribute(:active, false)
        assert !session.valid?
        assert session.errors[:base].size > 0
      end

      def test_validate_validate_magic_states_approved
        session = UserSession.new
        ben = users(:ben)
        session.unauthorized_record = ben
        assert session.valid?

        ben.update_attribute(:approved, false)
        assert !session.valid?
        assert session.errors[:base].size > 0
      end

      def test_validate_validate_magic_states_confirmed
        session = UserSession.new
        ben = users(:ben)
        session.unauthorized_record = ben
        assert session.valid?

        ben.update_attribute(:confirmed, false)
        assert !session.valid?
        assert session.errors[:base].size > 0
      end
    end
  end
end
