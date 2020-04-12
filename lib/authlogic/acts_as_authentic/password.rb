# frozen_string_literal: true

module Authlogic
  module ActsAsAuthentic
    # This module has a lot of neat functionality. It is responsible for encrypting your
    # password, salting it, and verifying it. It can also help you transition to a new
    # encryption algorithm. See the Config sub module for configuration options.
    module Password
      def self.included(klass)
        klass.class_eval do
          extend Config
          add_acts_as_authentic_module(Callbacks)
          add_acts_as_authentic_module(Methods)
        end
      end

      # All configuration for the password aspect of acts_as_authentic.
      module Config
        # The name of the crypted_password field in the database.
        #
        # * <tt>Default:</tt> :crypted_password, :encrypted_password, :password_hash, or :pw_hash
        # * <tt>Accepts:</tt> Symbol
        def crypted_password_field(value = nil)
          rw_config(
            :crypted_password_field,
            value,
            first_column_to_exist(
              nil,
              :crypted_password,
              :encrypted_password,
              :password_hash,
              :pw_hash
            )
          )
        end
        alias crypted_password_field= crypted_password_field

        # The name of the password_salt field in the database.
        #
        # * <tt>Default:</tt> :password_salt, :pw_salt, :salt, nil if none exist
        # * <tt>Accepts:</tt> Symbol
        def password_salt_field(value = nil)
          rw_config(
            :password_salt_field,
            value,
            first_column_to_exist(nil, :password_salt, :pw_salt, :salt)
          )
        end
        alias password_salt_field= password_salt_field

        # Whether or not to require a password confirmation. If you don't want your users
        # to confirm their password just set this to false.
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def require_password_confirmation(value = nil)
          rw_config(:require_password_confirmation, value, true)
        end
        alias require_password_confirmation= require_password_confirmation

        # By default passwords are required when a record is new or the crypted_password
        # is blank, but if both of these things are met a password is not required. In
        # this case, blank passwords are ignored.
        #
        # Think about a profile page, where the user can edit all of their information,
        # including changing their password. If they do not want to change their password
        # they just leave the fields blank. This will try to set the password to a blank
        # value, in which case is incorrect behavior. As such, Authlogic ignores this. But
        # let's say you have a completely separate page for resetting passwords, you might
        # not want to ignore blank passwords. If this is the case for you, then just set
        # this value to false.
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def ignore_blank_passwords(value = nil)
          rw_config(:ignore_blank_passwords, value, true)
        end
        alias ignore_blank_passwords= ignore_blank_passwords

        # When calling valid_password?("some pass") do you want to check that password
        # against what's in that object or whats in the database. Take this example:
        #
        #   u = User.first
        #   u.password = "new pass"
        #   u.valid_password?("old pass")
        #
        # Should the last line above return true or false? The record hasn't been saved
        # yet, so most would assume true. Other would assume false. So I let you decide by
        # giving you this option.
        #
        # * <tt>Default:</tt> true
        # * <tt>Accepts:</tt> Boolean
        def check_passwords_against_database(value = nil)
          rw_config(:check_passwords_against_database, value, true)
        end
        alias check_passwords_against_database= check_passwords_against_database

        # The class you want to use to encrypt and verify your encrypted
        # passwords. See the Authlogic::CryptoProviders module for more info on
        # the available methods and how to create your own.
        #
        # The family of adaptive hash functions (BCrypt, SCrypt, PBKDF2) is the
        # best choice for password storage today. We recommend SCrypt. Other
        # one-way functions like SHA512 are inferior, but widely used.
        # Reversible functions like AES256 are the worst choice, and we no
        # longer support them.
        #
        # You can use the `transition_from_crypto_providers` option to gradually
        # transition to a better crypto provider without causing your users any
        # pain.
        #
        # * <tt>Default:</tt> There is no longer a default value. Prior to
        #   Authlogic 6, the default was `CryptoProviders::SCrypt`. If you try
        #   to read this config option before setting it, it will raise a
        #   `NilCryptoProvider` error. See that error's message for further
        #   details, and rationale for this change.
        # * <tt>Accepts:</tt> Class
        def crypto_provider
          acts_as_authentic_config[:crypto_provider].tap { |provider|
            raise NilCryptoProvider if provider.nil?
          }
        end

        def crypto_provider=(value)
          raise NilCryptoProvider if value.nil?
          CryptoProviders::Guidance.new(value).impart_wisdom
          rw_config(:crypto_provider, value)
        end

        # Let's say you originally encrypted your passwords with Sha1. Sha1 is
        # starting to join the party with MD5 and you want to switch to
        # something stronger. No problem, just specify your new and improved
        # algorithm with the crypt_provider option and then let Authlogic know
        # you are transitioning from Sha1 using this option. Authlogic will take
        # care of everything, including transitioning your users to the new
        # algorithm. The next time a user logs in, they will be granted access
        # using the old algorithm and their password will be resaved with the
        # new algorithm. All new users will obviously use the new algorithm as
        # well.
        #
        # Lastly, if you want to transition again, you can pass an array of
        # crypto providers. So you can transition from as many algorithms as you
        # want.
        #
        # * <tt>Default:</tt> nil
        # * <tt>Accepts:</tt> Class or Array
        def transition_from_crypto_providers(value = nil)
          rw_config(
            :transition_from_crypto_providers,
            (!value.nil? && [value].flatten.compact) || value,
            []
          )
        end
        alias transition_from_crypto_providers= transition_from_crypto_providers
      end

      # Callbacks / hooks to allow other modules to modify the behavior of this module.
      module Callbacks
        # Does the order of this array matter?
        METHODS = %w[
          password_set
          password_verification
        ].freeze

        def self.included(klass)
          return if klass.crypted_password_field.nil?
          klass.send :extend, ActiveModel::Callbacks
          METHODS.each do |method|
            klass.define_model_callbacks method, only: %i[before after]
          end
        end
      end

      # The methods related to the password field.
      module Methods
        def self.included(klass)
          return if klass.crypted_password_field.nil?

          klass.class_eval do
            include InstanceMethods
            after_save :reset_password_changed
          end
        end

        # :nodoc:
        module InstanceMethods
          # The password
          def password
            return nil unless defined?(@password)
            @password
          end

          # This is a virtual method. Once a password is passed to it, it will
          # create new password salt as well as encrypt the password.
          def password=(pass)
            return if ignore_blank_passwords? && pass.blank?
            run_callbacks :password_set do
              @password = pass
              if password_salt_field
                send("#{password_salt_field}=", Authlogic::Random.friendly_token)
              end
              send(
                "#{crypted_password_field}=",
                crypto_provider.encrypt(*encrypt_arguments(@password, false))
              )
              @password_changed = true
            end
          end

          # Accepts a raw password to determine if it is the correct password.
          #
          # - attempted_password [String] - password entered by user
          # - check_against_database [boolean] - Should we check the password
          #   against the value in the database or the value in the object?
          #   Default taken from config option check_passwords_against_database.
          #   See config method for more information.
          def valid_password?(
            attempted_password,
            check_against_database = check_passwords_against_database?
          )
            crypted = crypted_password_to_validate_against(check_against_database)
            return false if attempted_password.blank? || crypted.blank?
            run_callbacks :password_verification do
              crypto_providers.each_with_index.any? do |encryptor, index|
                if encryptor_matches?(
                  crypted,
                  encryptor,
                  attempted_password,
                  check_against_database
                )
                  if transition_password?(index, encryptor, check_against_database)
                    transition_password(attempted_password)
                  end
                  true
                else
                  false
                end
              end
            end
          end

          # Resets the password to a random friendly token.
          def reset_password
            friendly_token = Authlogic::Random.friendly_token
            self.password = friendly_token
            self.password_confirmation = friendly_token if self.class.require_password_confirmation
          end
          alias randomize_password reset_password

          # Resets the password to a random friendly token and then saves the record.
          def reset_password!
            reset_password
            save_without_session_maintenance(validate: false)
          end
          alias randomize_password! reset_password!

          private

          def crypted_password_to_validate_against(check_against_database)
            if check_against_database && send("will_save_change_to_#{crypted_password_field}?")
              send("#{crypted_password_field}_in_database")
            else
              send(crypted_password_field)
            end
          end

          def check_passwords_against_database?
            self.class.check_passwords_against_database == true
          end

          def crypto_providers
            [crypto_provider] + transition_from_crypto_providers
          end

          # Returns an array of arguments to be passed to a crypto provider, either its
          # `matches?` or its `encrypt` method.
          def encrypt_arguments(raw_password, check_against_database)
            salt = nil
            if password_salt_field
              salt =
                if check_against_database && send("will_save_change_to_#{password_salt_field}?")
                  send("#{password_salt_field}_in_database")
                else
                  send(password_salt_field)
                end
            end
            [raw_password, salt].compact
          end

          # Given `encryptor`, does `attempted_password` match the `crypted` password?
          def encryptor_matches?(crypted, encryptor, attempted_password, check_against_database)
            encryptor_args = encrypt_arguments(attempted_password, check_against_database)
            encryptor.matches?(crypted, *encryptor_args)
          end

          # Determines if we need to transition the password.
          #
          # - If the index > 0 then we are using a "transition from" crypto
          #   provider.
          # - If the encryptor has a cost and the cost it outdated.
          # - If we aren't using database values
          # - If we are using database values, only if the password hasn't
          #   changed so we don't overwrite any changes
          def transition_password?(index, encryptor, check_against_database)
            (
              index > 0 ||
              (encryptor.respond_to?(:cost_matches?) &&
              !encryptor.cost_matches?(send(crypted_password_field)))
            ) &&
              (
                !check_against_database ||
                !send("will_save_change_to_#{crypted_password_field}?")
              )
          end

          def transition_password(attempted_password)
            self.password = attempted_password
            save(validate: false)
          end

          def require_password?
            # this is _not_ the activemodel changed? method, see below
            new_record? || password_changed? || send(crypted_password_field).blank?
          end

          def ignore_blank_passwords?
            self.class.ignore_blank_passwords == true
          end

          def password_changed?
            defined?(@password_changed) && @password_changed == true
          end

          def reset_password_changed
            @password_changed = nil
          end

          def crypted_password_field
            self.class.crypted_password_field
          end

          def password_salt_field
            self.class.password_salt_field
          end

          def crypto_provider
            self.class.crypto_provider
          end

          def transition_from_crypto_providers
            self.class.transition_from_crypto_providers
          end
        end
      end
    end
  end
end
