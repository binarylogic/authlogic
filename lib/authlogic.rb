require "active_support"

require File.dirname(__FILE__) + "/authlogic/version"

require File.dirname(__FILE__) + "/authlogic/controller_adapters/abstract_adapter"
require File.dirname(__FILE__) + "/authlogic/controller_adapters/rails_adapter" if defined?(Rails)
require File.dirname(__FILE__) + "/authlogic/controller_adapters/merb_adapter" if defined?(Merb)

require File.dirname(__FILE__) + "/authlogic/crypto_providers/sha1"
require File.dirname(__FILE__) + "/authlogic/crypto_providers/sha512"

if defined?(ActiveRecord)
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/credentials"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/logged_in"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/persistence"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/session_maintenance"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/authenticates_many"
end

require File.dirname(__FILE__) + "/authlogic/session/scoped"
require File.dirname(__FILE__) + "/authlogic/session/active_record_trickery"
require File.dirname(__FILE__) + "/authlogic/session/callbacks"
require File.dirname(__FILE__) + "/authlogic/session/config"
require File.dirname(__FILE__) + "/authlogic/session/cookies"
require File.dirname(__FILE__) + "/authlogic/session/errors"
require File.dirname(__FILE__) + "/authlogic/session/session"
require File.dirname(__FILE__) + "/authlogic/session/scopes"
require File.dirname(__FILE__) + "/authlogic/session/base"

module Authlogic
  module Session
    class Base
      include ActiveRecordTrickery
      include Callbacks
      include Cookies
      include Session
      include Scopes
    end
  end
end