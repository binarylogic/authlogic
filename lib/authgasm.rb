require "digest/sha2"
require File.dirname(__FILE__) + "/authgasm/version"

require File.dirname(__FILE__) + "/authgasm/controller_adapters/rails_adapter" if defined?(Rails)

require File.dirname(__FILE__) + "/authgasm/sha256_crypto_provider"
require File.dirname(__FILE__) + "/authgasm/acts_as_authentic"
require File.dirname(__FILE__) + "/authgasm/session/active_record_trickery"
require File.dirname(__FILE__) + "/authgasm/session/callbacks"
require File.dirname(__FILE__) + "/authgasm/session/config"
require File.dirname(__FILE__) + "/authgasm/session/errors"
require File.dirname(__FILE__) + "/authgasm/session/base"

module Authgasm
  module Session
    class Base
      include ActiveRecordTrickery
      include Callbacks
    end
  end
end