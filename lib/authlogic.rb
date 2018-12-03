# frozen_string_literal: true

# Authlogic uses ActiveSupport's core extensions like `strip_heredoc` and
# `squish`. ActiveRecord does not `require` these exensions, so we must.
#
# It's possible that we could save a few milliseconds by loading only the
# specific core extensions we need, but `all.rb` is simpler. We can revisit this
# decision if it becomes a problem.
require "active_support/all"

require "active_record"

path = File.dirname(__FILE__) + "/authlogic/"

[
  "i18n",
  "random",
  "config",

  "controller_adapters/abstract_adapter",

  "crypto_providers",

  "acts_as_authentic/email",
  "acts_as_authentic/logged_in_status",
  "acts_as_authentic/login",
  "acts_as_authentic/magic_columns",
  "acts_as_authentic/password",
  "acts_as_authentic/perishable_token",
  "acts_as_authentic/persistence_token",
  "acts_as_authentic/session_maintenance",
  "acts_as_authentic/single_access_token",
  "acts_as_authentic/base",

  "session/activation",
  "session/active_record_trickery",
  "session/brute_force_protection",
  "session/callbacks",
  "session/cookies",
  "session/existence",
  "session/foundation",
  "session/http_auth",
  "session/id",
  "session/klass",
  "session/magic_column/assigns_last_request_at",
  "session/magic_columns",
  "session/magic_states",
  "session/params",
  "session/password",
  "session/perishable_token",
  "session/persistence",
  "session/priority_record",
  "session/scopes",
  "session/session",
  "session/timeout",
  "session/unauthorized_record",
  "session/validation",
  "session/base"
].each do |library|
  require path + library
end

require path + "controller_adapters/rails_adapter"   if defined?(Rails)
require path + "controller_adapters/sinatra_adapter" if defined?(Sinatra)
