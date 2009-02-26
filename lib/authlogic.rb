require "active_support"

require File.dirname(__FILE__) + "/authlogic/version"
require File.dirname(__FILE__) + "/authlogic/i18n"
require File.dirname(__FILE__) + "/authlogic/random"

require File.dirname(__FILE__) + "/authlogic/controller_adapters/abstract_adapter"
require File.dirname(__FILE__) + "/authlogic/controller_adapters/rails_adapter" if defined?(Rails)
require File.dirname(__FILE__) + "/authlogic/controller_adapters/merb_adapter" if defined?(Merb)

require File.dirname(__FILE__) + "/authlogic/crypto_providers/sha1"
require File.dirname(__FILE__) + "/authlogic/crypto_providers/sha512"
require File.dirname(__FILE__) + "/authlogic/crypto_providers/bcrypt"
require File.dirname(__FILE__) + "/authlogic/crypto_providers/aes256"

if defined?(ActiveRecord)
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/base"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/credentials"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/logged_in"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/perishability"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/persistence"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/session_maintenance"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/single_access"
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/acts_as_authentic/config" # call this last so the configuration options are passed down the chain
  require File.dirname(__FILE__) + "/authlogic/orm_adapters/active_record_adapter/authenticates_many"
end

require File.dirname(__FILE__) + "/authlogic/session/authenticates_many_association"
require File.dirname(__FILE__) + "/authlogic/session/active_record_trickery"
require File.dirname(__FILE__) + "/authlogic/session/brute_force_protection"
require File.dirname(__FILE__) + "/authlogic/session/callbacks"
require File.dirname(__FILE__) + "/authlogic/session/config"
require File.dirname(__FILE__) + "/authlogic/session/cookies"
require File.dirname(__FILE__) + "/authlogic/session/errors"
require File.dirname(__FILE__) + "/authlogic/session/params"
require File.dirname(__FILE__) + "/authlogic/session/perishability"
require File.dirname(__FILE__) + "/authlogic/session/record_info"
require File.dirname(__FILE__) + "/authlogic/session/session"
require File.dirname(__FILE__) + "/authlogic/session/scopes"
require File.dirname(__FILE__) + "/authlogic/session/timeout"
require File.dirname(__FILE__) + "/authlogic/session/base"

module Authlogic
  module Session
    class Base
      include ActiveRecordTrickery
      include Callbacks
      include BruteForceProtection
      include Cookies
      include Params
      include Perishability
      include RecordInfo
      include Session
      include Scopes
      include Timeout
    end
  end
end