# frozen_string_literal: true

require_relative "authlogic/errors"
require_relative "authlogic/i18n"
require_relative "authlogic/random"
require_relative "authlogic/config"

require_relative "authlogic/controller_adapters/abstract_adapter"
require_relative "authlogic/cookie_credentials"

require_relative "authlogic/crypto_providers"

require_relative "authlogic/acts_as_authentic/email"
require_relative "authlogic/acts_as_authentic/logged_in_status"
require_relative "authlogic/acts_as_authentic/login"
require_relative "authlogic/acts_as_authentic/magic_columns"
require_relative "authlogic/acts_as_authentic/password"
require_relative "authlogic/acts_as_authentic/perishable_token"
require_relative "authlogic/acts_as_authentic/persistence_token"
require_relative "authlogic/acts_as_authentic/session_maintenance"
require_relative "authlogic/acts_as_authentic/single_access_token"
require_relative "authlogic/acts_as_authentic/base"

require_relative "authlogic/session/magic_column/assigns_last_request_at"
require_relative "authlogic/session/base"

# Authlogic uses ActiveSupport's core extensions like `strip_heredoc` and
# `squish`. ActiveRecord does not `require` these exensions, so we must.
#
# It's possible that we could save a few milliseconds by loading only the
# specific core extensions we need, but `all.rb` is simpler. We can revisit this
# decision if it becomes a problem.
require "active_support/all"

require_relative "authlogic/controller_adapters/rails_adapter" if defined?(Rails)
require_relative "authlogic/controller_adapters/sinatra_adapter" if defined?(Sinatra)
