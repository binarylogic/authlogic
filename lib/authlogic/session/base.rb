module Authlogic
  module Session # :nodoc:
    # This is the most important class in Authlogic. You will inherit this class
    # for your own eg. `UserSession`.
    #
    # Code is organized topically. Each topic is represented by a module. So, to
    # learn about password-based authentication, read the `Password` module.
    #
    # It is common for methods (.initialize and #credentials=, for example) to
    # be implemented in multiple mixins. Those methods will call `super`, so the
    # order of `include`s here is important.
    #
    # Also, to fully understand such a method (like #credentials=) you will need
    # to mentally combine all of its definitions. This is perhaps the primary
    # disadvantage of topical organization using modules.
    class Base
      include Foundation
      include Callbacks

      # Included first so that the session resets itself to nil
      include Timeout

      # Included in a specific order so they are tried in this order when persisting
      include Params
      include Cookies
      include Session
      include HttpAuth

      # Included in a specific order so magic states gets run after a record is found
      # TODO: What does "magic states gets run" mean? Be specific.
      include Password
      include UnauthorizedRecord
      include MagicStates

      include Activation
      include ActiveRecordTrickery
      include BruteForceProtection
      include Existence
      include Klass
      include MagicColumns
      include PerishableToken
      include Persistence
      include Scopes
      include Id
      include Validation
      include PriorityRecord
    end
  end
end
