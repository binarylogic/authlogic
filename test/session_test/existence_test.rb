require 'test_helper'

module SessionTest
  module ExistenceTest
    class ClassMethodsTest < ActiveSupport::TestCase
      def test_create_with_good_credentials
        ben = users(:ben)
        session = UserSession.create(login: ben.login, password: "benrocks")
        refute session.new_session?
      end

      def test_create_with_bad_credentials
        session = UserSession.create(login: "somelogin", password: "badpw2")
        assert session.new_session?
      end

      def test_create_bang
        ben = users(:ben)
        err = assert_raise(Authlogic::Session::Existence::SessionInvalidError) do
          UserSession.create!(login: ben.login, password: "badpw")
        end
        assert_includes err.message, "Password is not valid"
        refute UserSession.create!(login: ben.login, password: "benrocks").new_session?
      end
    end

    class InstanceMethodsTest < ActiveSupport::TestCase
      def test_new_session
        session = UserSession.new
        assert session.new_session?

        set_session_for(users(:ben))
        session = UserSession.find
        refute session.new_session?
      end

      def test_save_with_nothing
        session = UserSession.new
        refute session.save
        assert session.new_session?
      end

      def test_save_with_block
        session = UserSession.new
        block_result = session.save do |result|
          refute result
        end
        refute block_result
        assert session.new_session?
      end

      def test_save_with_bang
        session = UserSession.new
        assert_raise(Authlogic::Session::Existence::SessionInvalidError) { session.save! }

        session.unauthorized_record = users(:ben)
        assert_nothing_raised { session.save! }
      end

      def test_destroy
        ben = users(:ben)
        session = UserSession.new
        refute session.valid?
        refute session.errors.empty?
        assert session.destroy
        assert session.errors.empty?
        session.unauthorized_record = ben
        assert session.save
        assert session.record
        assert session.destroy
        refute session.record
      end
    end

    class SessionInvalidErrorTest < ActiveSupport::TestCase
      def test_message
        session = UserSession.new
        assert !session.valid?
        error = Authlogic::Session::Existence::SessionInvalidError.new(session)
        message = "Your session is invalid and has the following errors: " +
          session.errors.full_messages.to_sentence
        assert_equal message, error.message
      end
    end
  end
end
