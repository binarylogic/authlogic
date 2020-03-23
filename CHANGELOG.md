# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

* Breaking Changes, Major
  * There is no longer a default `crypto_provider`. We still recommend SCrypt,
    but don't want users of other providers to be forced to install it. You
    must now explicitly specify your `crypto_provider`, eg. in your `user.rb`.

        acts_as_authentic do |config|
          c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
        end

    To continue to use the `scrypt` gem, add it to your `Gemfile`.

        gem "scrypt", "~> 3.0"

* Breaking Changes, Minor
  * The arity of `crypto_provider` has changed from -1 (one optional arg) to 0
    (no arguments). To set the provider, use `crypto_provider=`.
* Added
  * The ability to specify "None" as a valid SameSite attribute to address change in default SameSite behavior from Chromium project and probably other browsers soon.
* Fixed
  * [#686](https://github.com/binarylogic/authlogic/pull/686) - Respect
    the `log_in_after_create` setting when creating a new logged-out user
  * [#668](https://github.com/binarylogic/authlogic/pull/668) -
    BCrypt user forced to load SCrypt
  * [#697](https://github.com/binarylogic/authlogic/issues/697) - Add V2 CryptoProviders  for MD5 and SHA schemes that fix key stretching by hashing the byte digests instead of the hex strings representing those digests

## 5.0.4 (2019-09-11)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#681](https://github.com/binarylogic/authlogic/pull/681) -
    Delete unnecessary `AuthlogicLoadedTooLateError`

## 5.0.3 (2019-09-07)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#678](https://github.com/binarylogic/authlogic/pull/678) -
    Fix `ActionText` deprecation warning by lazily loading controller adapter

## 5.0.2 (2019-04-21)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#665](https://github.com/binarylogic/authlogic/pull/665) -
    Explicitly set case_sensitive: true for validates_uniqueness_of validation
    due to deprecation in Rails 6.0
  * [#659](https://github.com/binarylogic/authlogic/pull/659) -
    Fixed an issue affecting case-sensitive searches in MySQL

## 5.0.1 (2019-02-13)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#650](https://github.com/binarylogic/authlogic/pull/650) -
    rails 6.0.0.beta1 made a breaking change to case_insensitive_comparison

## 5.0.0 (2019-01-04)

* Breaking Changes
  * Likely to affect many people
    * [#629](https://github.com/binarylogic/authlogic/pull/629) -
      Drop validations deprecated in 4.4.0.
      * See [doc/use_normal_rails_validation.md][1]
      * [#640](https://github.com/binarylogic/authlogic/pull/640) -
        Drop `Authlogic::Regex`
    * [#628](https://github.com/binarylogic/authlogic/pull/628) -
      Drop `authenticates_many`, deprecated in 4.4.0
  * Likely to affect few people
    * [#617](https://github.com/binarylogic/authlogic/pull/617) -
      Drop AES-256 crypto provider, deprecated in 4.2.0
    * [#617](https://github.com/binarylogic/authlogic/pull/617) -
      Drop restful_authentication, deprecated in 4.1.0
  * Unlikely to affect anyone
    * [#647](https://github.com/binarylogic/authlogic/pull/647) -
      Drop the wordpress crypto provider, deprecated in 4.1.0
    * [#618](https://github.com/binarylogic/authlogic/pull/618) -
      Uses `frozen_string_literal`, so assume all strings returned are frozen
    * [#642](https://github.com/binarylogic/authlogic/pull/642) -
      The modules that were mixed into `Authlogic::Session::Base` have been
      inlined and deleted. This only affects you if you were re-opening
      ("monkey-patching") one of the deleted modules, in which case you can
      re-open `Base` instead.
    * [#648](https://github.com/binarylogic/authlogic/pull/648) -
      `Session::Base#credentials` now always returns a hash.
* Added
  * None
* Fixed
  * [#638](https://github.com/binarylogic/authlogic/pull/638) -
    Address Rails 5.1 changes to ActiveModel::Dirty
* Dependencies
  * [#632](https://github.com/binarylogic/authlogic/pull/632) -
    Add support for rails 6.0, drop support for rails < 5.2. See
    [doc/rails_support_in_authlogic_5.0.md](https://git.io/fpK7j) for details.
  * [#645](https://github.com/binarylogic/authlogic/pull/645) -
    Add support for ruby 2.6

## 4.4.2 (2018-09-23)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * Improved instructions in deprecation warning for validations

## 4.4.1 (2018-09-21)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * The methods for disabling Authlogic's "special" validations,
    eg. `validate_email_field = false` are actually deprecated, but should
    not produce a deprecation warning.
  * Only produce deprecation warning when configuring a validation, not when
    performing actual validation.

## 4.4.0 (2018-09-21)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * None
* Deprecation
  * [#627](https://github.com/binarylogic/authlogic/pull/627) -
    Deprecate `authenticates_many` without replacement
  * [#623](https://github.com/binarylogic/authlogic/pull/623) -
    Deprecate unnecessary validation features, use normal rails validation
    instead. See [doc/use_normal_rails_validation.md][1]

## 4.3.0 (2018-08-12)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * None
* Dependencies
  * Drop support for ruby 2.2, which reached EoL on 2018-06-20

## 4.2.0 (2018-07-18)

* Breaking Changes
  * None
* Added
  * [#611](https://github.com/binarylogic/authlogic/pull/611) - Deprecate
    AES256, guide users to choose a better crypto provider
* Fixed
  * None

## 4.1.1 (2018-05-23)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#606](https://github.com/binarylogic/authlogic/pull/606) - Interpreter
    warnings about undefined instance variables

## 4.1.0 (2018-04-24)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * None
* Deprecated
  * crypto_providers/wordpress.rb, without replacement
  * restful_authentication, without replacement

## 4.0.1 (2018-03-20)

* Breaking Changes
  * None
* Added
  * None
* Fixed
  * [#590](https://github.com/binarylogic/authlogic/pull/590) -
    Fix "cannot modify frozen gem" re: ActiveRecord.gem_version

## 4.0.0 (2018-03-18)

* Breaking Changes, Major
  * Drop support for ruby < 2.2
  * Drop support for rails < 4.2
  * HTTP Basic Auth is now disabled by default (use allow_http_basic_auth to enable)
  * 'httponly' and 'secure' cookie options are enabled by default now
  * maintain_sessions config has been removed. It has been split into 2 new options:
    log_in_after_create & log_in_after_password_change (@lucasminissale)
  * [#558](https://github.com/binarylogic/authlogic/pull/558) Passing an
    ActionController::Parameters into authlogic will now raise an error

* Breaking Changes, Minor
  * Methods in Authlogic::Random are now module methods, and are no longer
    instance methods. Previously, there were both. Do not use Authlogic::Random
    as a mixin.
  * Our mutable constants (e.g. arrays, hashes) are now frozen.

* Added
  * `Authlogic.gem_version`
  * [#586](https://github.com/binarylogic/authlogic/pull/586) Support for SameSite cookies
  * [#581](https://github.com/binarylogic/authlogic/pull/581) Support for rails 5.2
  * Support for ruby 2.4, specifically openssl gem 2.0
  * [#98](https://github.com/binarylogic/authlogic/issues/98)
    I18n for invalid session error message. (@eugenebolshakov)

* Fixed
  * Random.friendly_token (used for e.g. perishable token) now returns strings
    of consistent length, and conforms better to RFC-4648
  * ensure that login field validation uses correct locale (@sskirby)
  * add a respond_to_missing? in AbstractAdapter that also checks controller respond_to?
  * [#561](https://github.com/binarylogic/authlogic/issues/561) authenticates_many now works with scope_cookies:true
  * Allow tld up to 25 characters per https://data.iana.org/TLD/tlds-alpha-by-domain.txt

## 3.8.0 2018-02-07

* Breaking Changes
  * None

* Added
  * [#582](https://github.com/binarylogic/authlogic/pull/582) Support rails 5.2
  * [#583](https://github.com/binarylogic/authlogic/pull/583) Support openssl gem 2.0

* Fixed
  * None

## 3.7.0 2018-02-07

* Breaking Changes
  * None

* Added
  * [#580](https://github.com/binarylogic/authlogic/pull/580) Deprecated
    `ActionController::Parameters`, will be removed in 4.0.0

* Fixed
  * None

## 3.6.1 2017-09-30

* Breaking Changes
  * None

* Added
  * None

* Fixed
  * Allow TLD up to 24 characters per
    https://data.iana.org/TLD/tlds-alpha-by-domain.txt
  * [#561](https://github.com/binarylogic/authlogic/issues/561)
    authenticates_many now works with scope_cookies:true

## 3.6.0 2017-04-28

* Breaking Changes
  * None

* Added
  * Support rails 5.1

* Fixed
  * ensure that login field validation uses correct locale (@sskirby)

## 3.5.0 2016-08-29

* new
  * Rails 5.0 support! Thanks to all reporters and contributors.

* changes
  * increased default minimum password length to 8 (@iainbeeston)
  * bind parameters in where statement for rails 5 support
  * change callback for rails 5 support
  * converts the ActionController::Parameters to a Hash for rails 5 support
  * check last_request_at_threshold even if last_request_at_update_allowed returns true (@rofreg)

## 3.4.6 2015

* changes
  * add Regex.email_nonascii for validation of emails w/unicode (@rchekaluk)
  * allow scrypt 2.x (@jaredbeck)

## 3.4.5 2015-03-01

* changes
  * security-hardening fix and cleanup in persistence_token lookup
  * security-hardening fix in perishable_token lookup (thx @tomekr)

## 3.4.4 2014-12-23

* changes
  * extract rw_config into an Authlogic::Config module
  * improved the way config changes are made in tests
  * fix for Rails 4.2 by extending ActiveModel

## 3.4.3 2014-10-08

* changes
  * backfill CHANGELOG
  * better compatibility with jruby (thx @petergoldstein)
  * added scrypt as a dependency
  * cleanup some code (thx @roryokane)
  * reference 'bcrypt' gem instead of 'bcrypt-ruby' (thx @roryokane)
  * fixed typo (thx @chamini2)
  * fixed magic column validations for Rails 4.2 (thx @tom-kuca)

## 3.4.2 2014-04-28

* changes
  * fixed the missing scrypt/bcrypt gem errors introduced in 3.4.1
  * implemented autoloading for providers
  * added longer subdomain support in email regex

## 3.4.1 2014-04-04

* changes
  * undid an accidental revert of some code

## 3.4.0 2014-03-03

* Breaking Changes
  * made scrypt the default crypto provider from SHA512
    (https://github.com/binarylogic/authlogic#upgrading-to-authlogic-340)
    See UPGRADING.md.

* Added
  * officially support rails 4 (still supporting rails 3)
  * added cookie signing
  * added request store for better concurency for threaded environments
  * added a rack adapter for Rack middleware support

* Fixed
  * ditched appraisal
  * improved find_with_case default performance
  * added travis ci support

## 3.3.0 2014-04-04

* changes
  * added safeguard against a sqli that was also fixed in rails 3.2.10/3.1.9/3.0.18
  * imposed the bcrypt gem's mincost
  * removed shoulda macros

## 3.2.0 2012-12-07

* new
  * scrypt support

* changes
  * moved back to LOWER for find_with_case ci lookups

## 3.1.3 2012-06-13

* changes
  * removed jeweler

## 3.1.2 2012-06-01

* changes
  * mostly test fixes

## 3.1.1 2012-06-01

* changes
  * mostly doc fixes

## 3.1.0 2011-10-19

* changes
  * mostly small bug fixes

## 3.0.3 2011-05-17

* changes
  * rails 3.1 support

* new
  * http auth support

## 3.0.2 2011-04-30

* changes
  * doc fixes

## 3.0.1 2011-04-30

* changes
  * switch from LOWER to LIKE for find_with_case ci lookups

## 3.0.0 2011-04-30

* new
  * ssl cookie support
  * httponly cookie support
  * added a session generator

* changes
  * rails 3 support
  * ruby 1.9.2 support

[1]: https://github.com/binarylogic/authlogic/blob/master/doc/use_normal_rails_validation.md
