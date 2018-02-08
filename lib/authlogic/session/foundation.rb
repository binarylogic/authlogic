module Authlogic
  module Session
    # Sort of like an interface, it sets the foundation for the class, such as the
    # required methods. This also allows other modules to overwrite methods and call super
    # on them. It's also a place to put "utility" methods used throughout Authlogic.
    module Foundation
      def self.included(klass)
        klass.class_eval do
          extend Authlogic::Config
          include InstanceMethods
        end
      end

      module InstanceMethods
        E_AC_PARAMETERS = <<-EOS.strip_heredoc.freeze
          Passing an ActionController::Parameters to Authlogic is not allowed.

          In Authlogic 3, especially during the transition of rails to Strong
          Parameters, it was common for Authlogic users to forget to `permit`
          their params. They would pass their params into Authlogic, we'd call
          `to_h`, and they'd be surprised when authentication failed.

          In 2018, people are still making this mistake. We'd like to help them
          and make authlogic a little simpler at the same time, so in Authlogic
          3.7.0, we deprecated the use of ActionController::Parameters. Instead,
          pass a plain Hash. Please replace:

              UserSession.new(user_session_params)
              UserSession.create(user_session_params)

          with

              UserSession.new(user_session_params.to_h)
              UserSession.create(user_session_params.to_h)

          And don't forget to `permit`!

          We discussed this issue thoroughly between late 2016 and early
          2018. Notable discussions include:

          - https://github.com/binarylogic/authlogic/issues/512
          - https://github.com/binarylogic/authlogic/pull/558
          - https://github.com/binarylogic/authlogic/pull/577
        EOS

        def initialize(*args)
          self.credentials = args
        end

        # The credentials you passed to create your session. See credentials= for more
        # info.
        def credentials
          []
        end

        # Set your credentials before you save your session. There are many
        # method signatures.
        #
        # ```
        # # A hash of credentials is most common
        # session.credentials = { login: "foo", password: "bar", remember_me: true }
        #
        # # You must pass an actual Hash, `ActionController::Parameters` is
        # # specifically not allowed.
        #
        # # You can pass an array of objects:
        # session.credentials = [my_user_object, true]
        #
        # # If you need to set an id (see `Authlogic::Session::Id`) pass it
        # # last. It needs be the last item in the array you pass, since the id
        # # is something that you control yourself, it should never be set from
        # # a hash or a form. Examples:
        # session.credentials = [
        #   {:login => "foo", :password => "bar", :remember_me => true},
        #   :my_id
        # ]
        # session.credentials = [my_user_object, true, :my_id]
        #
        # # Finally, there's priority_record
        # [{ priority_record: my_object }, :my_id]
        # ```
        def credentials=(values)
          normalized = Array.wrap(values)
          if normalized.first.class.name == "ActionController::Parameters"
            raise TypeError.new(E_AC_PARAMETERS)
          end
        end

        def inspect
          "#<#{self.class.name}: #{credentials.blank? ? "no credentials provided" : credentials.inspect}>"
        end

        private

          def build_key(last_part)
            last_part
          end
      end
    end
  end
end
