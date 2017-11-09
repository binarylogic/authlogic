require 'test_helper'

module SessionTest
  module ActiveRecordTrickeryTest
    class ClassMethodsTest < ActiveSupport::TestCase
      # If test_human_name is executed after test_i18n_of_human_name the test will fail.
      i_suck_and_my_tests_are_order_dependent!

      def test_human_attribute_name
        assert_equal "Some attribute", UserSession.human_attribute_name("some_attribute")
        assert_equal "Some attribute", UserSession.human_attribute_name(:some_attribute)
      end

      def test_human_name
        assert_equal "Usersession", UserSession.human_name
      end

      def test_i18n_of_human_name
        I18n.backend.store_translations 'en', authlogic: { models: { user_session: "MySession" } }
        assert_equal "MySession", UserSession.human_name
      end

      def test_i18n_of_model_name_human
        I18n.backend.store_translations 'en', authlogic: { models: { user_session: "MySession" } }
        assert_equal "MySession", UserSession.model_name.human
      end

      def test_model_name
        assert_equal "UserSession", UserSession.model_name.name
        assert_equal "user_session", UserSession.model_name.singular
        assert_equal "user_sessions", UserSession.model_name.plural
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_new_record
        session = UserSession.new
        assert session.new_record?
      end

      def test_to_key
        ben = users(:ben)
        session = UserSession.new(ben)
        assert_nil session.to_key

        session.save
        assert_not_nil session.to_key
        assert_equal ben.to_key, session.to_key
      end

      def test_persisted
        session = UserSession.new(users(:ben))
        refute session.persisted?

        session.save
        assert session.persisted?

        session.destroy
        refute session.persisted?
      end

      def test_destroyed?
        session = UserSession.create(users(:ben))
        refute session.destroyed?

        session.destroy
        assert session.destroyed?
      end

      def test_to_model
        session = UserSession.new
        assert_equal session, session.to_model
      end
    end
  end
end
