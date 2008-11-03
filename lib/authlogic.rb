require File.dirname(__FILE__) + "/authlogic/version"

require File.dirname(__FILE__) + "/authlogic/controller_adapters/abstract_adapter"
require File.dirname(__FILE__) + "/authlogic/controller_adapters/rails_adapter" if defined?(Rails)

require File.dirname(__FILE__) + "/authlogic/sha512_crypto_provider"

require File.dirname(__FILE__) + "/authlogic/active_record/acts_as_authentic"
require File.dirname(__FILE__) + "/authlogic/active_record/authenticates_many"
require File.dirname(__FILE__) + "/authlogic/active_record/scoped_session"

require File.dirname(__FILE__) + "/authlogic/session/active_record_trickery"
require File.dirname(__FILE__) + "/authlogic/session/callbacks"
require File.dirname(__FILE__) + "/authlogic/session/config"
require File.dirname(__FILE__) + "/authlogic/session/errors"
require File.dirname(__FILE__) + "/authlogic/session/base"

module Authlogic
  module Session
    class Base
      include ActiveRecordTrickery
      include Callbacks
    end
  end
end