# frozen_string_literal: true

require "test_helper"
require "authlogic/controller_adapters/rails_adapter"

module SessionTest
  class PersistenceTest < ActiveSupport::TestCase
    def test_find
      aaron = users(:aaron)
      refute UserSession.find
      UserSession.allow_http_basic_auth = true
      http_basic_auth_for(aaron) { assert UserSession.find }
      set_cookie_for(aaron)
      assert UserSession.find
      unset_cookie
      set_session_for(aaron)
      session = UserSession.find
      assert session
    end

    def test_find_in_api
      @controller = Authlogic::TestCase::MockAPIController.new
      UserSession.controller =
        Authlogic::ControllerAdapters::RailsAdapter.new(@controller)

      aaron = users(:aaron)
      refute UserSession.find

      UserSession.single_access_allowed_request_types = ["application/json"]
      set_params_for(aaron)
      set_request_content_type("application/json")
      assert UserSession.find
    end

    def test_persisting
      # tested thoroughly in test_find
    end

    def test_should_set_remember_me_on_the_next_request
      aaron = users(:aaron)
      session = UserSession.new(aaron)
      session.remember_me = true
      refute UserSession.remember_me
      assert session.save
      assert session.remember_me?
      session = UserSession.find(aaron)
      assert session.remember_me?
    end
  end
end
